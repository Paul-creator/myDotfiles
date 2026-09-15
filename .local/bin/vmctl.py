#!/usr/bin/env python3
from __future__ import annotations

import argparse
import os
import re
import shlex
import shutil
import socket
import subprocess
import sys
import time
from dataclasses import dataclass

DEFAULT_HOST = "atlasroot-r"
LIBVIRT_URI = "qemu:///system"

MANUAL = r"""
vmctl - libvirt VMs auf einem entfernten Rechner ueber SSH verwalten

AUFRUF
  vmctl [--host HOST] [--sudo] COMMAND [ARGS...]

STANDARD-HOST
  atlasroot-r

COMMANDS
  interactive                 Interaktives Menue starten
  list                        Alle VMs mit Status anzeigen
  info VM                     Details zu einer VM anzeigen
  start VM                    VM starten
  shutdown VM                 VM sauber herunterfahren
  reboot VM                   VM sauber neu starten
  destroy VM                  VM hart ausschalten (wie Strom weg)
  autostart VM on|off         Autostart ein-/ausschalten
  vncdisplay VM               VNC-Display der VM anzeigen
  vnc VM                      SSH-Tunnel fuer VNC aufbauen und Viewer oeffnen
  console VM                  Serielle libvirt-Konsole oeffnen
  man                         Diese Kurzreferenz anzeigen

OPTIONEN
  -H, --host HOST             SSH-Host/Alias; Standard: atlasroot-r
  --sudo                      virsh remote mit sudo -n ausfuehren
  -h, --help                  Hilfe anzeigen

BEISPIELE
  vmctl
  vmctl list
  vmctl start win11
  vmctl info win11
  vmctl shutdown win11
  vmctl autostart win11 on
  vmctl vncdisplay win11
  vmctl vnc win11
  vmctl --host atlasroot-r list

HINWEISE
  Die libvirt-Verbindung ist qemu:///system.
  Bei --sudo wird sudo -n verwendet; dafuer muss sudo ohne Passwort moeglich sein.
  'destroy' ist ein hartes Ausschalten und kann Datenverlust verursachen.
  'vnc' erwartet eine VNC-Grafik der VM und tunnelt den entfernten VNC-Port ueber SSH.
""".strip()


class VmctlError(RuntimeError):
    pass


@dataclass
class Remote:
    host: str
    use_sudo: bool = False

    def _virsh(self, *args: str) -> list[str]:
        cmd = ["virsh", "-c", LIBVIRT_URI, *args]
        if self.use_sudo:
            cmd = ["sudo", "-n", *cmd]
        return cmd

    def _ssh_cmd(self, remote_argv: list[str], tty: bool = False) -> list[str]:
        cmd = ["ssh"]
        if tty:
            cmd.append("-tt")
        cmd += [self.host, shlex.join(remote_argv)]
        return cmd

    def capture(self, *virsh_args: str) -> str:
        p = subprocess.run(
            self._ssh_cmd(self._virsh(*virsh_args)),
            text=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
        )
        if p.returncode != 0:
            msg = (p.stderr or p.stdout).strip()
            raise VmctlError(msg or f"Remote-Befehl fehlgeschlagen ({p.returncode})")
        return p.stdout.replace("\r", "").strip()

    def run(self, *virsh_args: str, tty: bool = False) -> int:
        return subprocess.run(self._ssh_cmd(self._virsh(*virsh_args), tty=tty)).returncode

    def names(self) -> list[str]:
        out = self.capture("list", "--all", "--name")
        return [line.strip() for line in out.splitlines() if line.strip()]

    def state(self, vm: str) -> str:
        return self.capture("domstate", vm)


def require_ssh() -> None:
    if shutil.which("ssh") is None:
        raise VmctlError("'ssh' wurde nicht gefunden.")


def list_vms(remote: Remote) -> None:
    names = remote.names()
    if not names:
        print("Keine virtuellen Maschinen gefunden.")
        return

    rows: list[tuple[str, str]] = []
    for name in names:
        try:
            state = remote.state(name)
        except VmctlError:
            state = "?"
        rows.append((name, state))

    width = max(len("NAME"), *(len(name) for name, _ in rows))
    print(f"{'NAME':<{width}}  STATUS")
    print(f"{'-' * width}  {'-' * 20}")
    for name, state in rows:
        print(f"{name:<{width}}  {state}")


def choose_vm(remote: Remote) -> str | None:
    names = remote.names()
    if not names:
        print("Keine virtuellen Maschinen gefunden.")
        return None

    print("\nVirtuelle Maschinen:")
    for i, name in enumerate(names, 1):
        try:
            state = remote.state(name)
        except VmctlError:
            state = "?"
        print(f"  {i:>2}) {name:<24} {state}")
    print("   0) Beenden")

    while True:
        value = input("\nVM waehlen: ").strip()
        if value in {"0", "q", "quit", "exit"}:
            return None
        if value.isdigit() and 1 <= int(value) <= len(names):
            return names[int(value) - 1]
        if value in names:
            return value
        print("Ungueltige Auswahl.")


def action_menu(remote: Remote, vm: str) -> bool:
    while True:
        try:
            state = remote.state(vm)
        except VmctlError:
            state = "?"

        print(f"\n{vm} [{state}]")
        print("  1) Info")
        print("  2) Start")
        print("  3) Shutdown")
        print("  4) Reboot")
        print("  5) Hart ausschalten (destroy)")
        print("  6) Autostart EIN")
        print("  7) Autostart AUS")
        print("  8) VNC-Display anzeigen")
        print("  9) VNC per SSH-Tunnel oeffnen")
        print(" 10) Serielle Konsole")
        print(" 11) Andere VM")
        print("  0) Beenden")

        choice = input("\nAktion: ").strip()

        if choice == "1":
            print(remote.capture("dominfo", vm))
        elif choice == "2":
            remote.run("start", vm)
        elif choice == "3":
            remote.run("shutdown", vm)
        elif choice == "4":
            remote.run("reboot", vm)
        elif choice == "5":
            confirm = input(f"{vm} wirklich HART ausschalten? [y/N] ").strip().lower()
            if confirm in {"y", "yes", "j", "ja"}:
                remote.run("destroy", vm)
        elif choice == "6":
            remote.run("autostart", vm)
        elif choice == "7":
            remote.run("autostart", "--disable", vm)
        elif choice == "8":
            print(remote.capture("vncdisplay", vm))
        elif choice == "9":
            open_vnc(remote, vm, auto_open=True)
        elif choice == "10":
            remote.run("console", vm, tty=True)
        elif choice == "11":
            return True
        elif choice in {"0", "q", "quit", "exit"}:
            return False
        else:
            print("Ungueltige Auswahl.")


def interactive(remote: Remote) -> None:
    while True:
        vm = choose_vm(remote)
        if vm is None:
            return
        if not action_menu(remote, vm):
            return


def free_local_port() -> int:
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        s.bind(("127.0.0.1", 0))
        return int(s.getsockname()[1])


def parse_vnc_port(display: str) -> int:
    # virsh liefert typischerweise ':0' oder '127.0.0.1:0'.
    m = re.search(r":(\d+)\s*$", display)
    if not m:
        raise VmctlError(f"VNC-Display konnte nicht ausgewertet werden: {display!r}")
    return 5900 + int(m.group(1))


def launch_url(url: str) -> bool:
    if sys.platform == "darwin" and shutil.which("open"):
        subprocess.Popen(["open", url])
        return True
    if shutil.which("xdg-open"):
        subprocess.Popen(["xdg-open", url])
        return True
    return False


def open_vnc(remote: Remote, vm: str, auto_open: bool) -> None:
    display = remote.capture("vncdisplay", vm)
    remote_port = parse_vnc_port(display)
    local_port = free_local_port()

    cmd = [
        "ssh",
        "-N",
        "-L",
        f"127.0.0.1:{local_port}:127.0.0.1:{remote_port}",
        remote.host,
    ]
    print(f"VNC: remote {display} -> localhost:{local_port}")
    print("SSH-Tunnel laeuft. Mit Ctrl+C beenden.")

    proc = subprocess.Popen(cmd)
    try:
        time.sleep(0.6)
        if proc.poll() is not None:
            raise VmctlError("SSH-Tunnel konnte nicht aufgebaut werden.")

        url = f"vnc://127.0.0.1:{local_port}"
        if auto_open:
            if not launch_url(url):
                print(url)
        else:
            print(url)
        proc.wait()
    except KeyboardInterrupt:
        pass
    finally:
        if proc.poll() is None:
            proc.terminate()
            try:
                proc.wait(timeout=2)
            except subprocess.TimeoutExpired:
                proc.kill()


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        prog="vmctl",
        description="libvirt-VMs auf einem entfernten Host ueber SSH verwalten.",
        epilog=(
            "Beispiele:\n"
            "  vmctl\n"
            "  vmctl list\n"
            "  vmctl start win11\n"
            "  vmctl shutdown win11\n"
            "  vmctl autostart win11 on\n"
            "  vmctl vnc win11\n"
            "  vmctl man"
        ),
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    parser.add_argument("-H", "--host", default=DEFAULT_HOST, help=f"SSH-Host/Alias (Standard: {DEFAULT_HOST})")
    parser.add_argument("--sudo", action="store_true", help="remote 'virsh' mit 'sudo -n' ausfuehren")

    sub = parser.add_subparsers(dest="command", metavar="COMMAND")

    sub.add_parser("interactive", help="interaktives Menue starten")
    sub.add_parser("list", help="alle VMs mit Status anzeigen")

    p = sub.add_parser("info", help="Details zu einer VM anzeigen")
    p.add_argument("vm")

    p = sub.add_parser("start", help="VM starten")
    p.add_argument("vm")

    p = sub.add_parser("shutdown", help="VM sauber herunterfahren")
    p.add_argument("vm")

    p = sub.add_parser("reboot", help="VM sauber neu starten")
    p.add_argument("vm")

    p = sub.add_parser("destroy", help="VM hart ausschalten")
    p.add_argument("vm")

    p = sub.add_parser("autostart", help="Autostart ein-/ausschalten")
    p.add_argument("vm")
    p.add_argument("mode", choices=["on", "off"])

    p = sub.add_parser("vncdisplay", help="VNC-Display anzeigen")
    p.add_argument("vm")

    p = sub.add_parser("vnc", help="VNC ueber SSH-Tunnel oeffnen")
    p.add_argument("vm")
    p.add_argument("--no-open", action="store_true", help="VNC-Viewer nicht automatisch oeffnen")

    p = sub.add_parser("console", help="serielle libvirt-Konsole oeffnen")
    p.add_argument("vm")

    sub.add_parser("man", help="Kurzreferenz anzeigen")
    return parser


def main() -> int:
    parser = build_parser()
    args = parser.parse_args()
    cmd = args.command or "interactive"

    try:
        if cmd == "man":
            print(MANUAL)
            return 0

        require_ssh()
        remote = Remote(args.host, args.sudo)
        if cmd == "interactive":
            interactive(remote)
        elif cmd == "list":
            list_vms(remote)
        elif cmd == "info":
            print(remote.capture("dominfo", args.vm))
        elif cmd == "start":
            return remote.run("start", args.vm)
        elif cmd == "shutdown":
            return remote.run("shutdown", args.vm)
        elif cmd == "reboot":
            return remote.run("reboot", args.vm)
        elif cmd == "destroy":
            return remote.run("destroy", args.vm)
        elif cmd == "autostart":
            if args.mode == "on":
                return remote.run("autostart", args.vm)
            return remote.run("autostart", "--disable", args.vm)
        elif cmd == "vncdisplay":
            print(remote.capture("vncdisplay", args.vm))
        elif cmd == "vnc":
            open_vnc(remote, args.vm, auto_open=not args.no_open)
        elif cmd == "console":
            return remote.run("console", args.vm, tty=True)
        else:
            parser.print_help()
            return 2
    except VmctlError as e:
        print(f"Fehler: {e}", file=sys.stderr)
        return 1
    except KeyboardInterrupt:
        print()
        return 130

    return 0


if __name__ == "__main__":
    raise SystemExit(main())

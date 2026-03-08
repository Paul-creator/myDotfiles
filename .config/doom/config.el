;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
;; (setq user-full-name "John Doe"
;;       user-mail-address "john@doe.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-symbol-font' -- for symbols
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
(setq doom-font (font-spec :family "Fira Code" :size 12 :weight 'semi-light)
      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-one)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type 'visual)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")


;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `with-eval-after-load' block, otherwise Doom's defaults may override your
;; settings. E.g.
;;
;;   (with-eval-after-load 'PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look them up).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.


(map! :n "C-h" #'evil-window-left
      :n "C-l" #'evil-window-right
      :n "C-k" #'evil-window-up
      :n "C-j" #'evil-window-down)

;; -----------------------------------------------------------------------------
;; VHDL
;; -----------------------------------------------------------------------------

(use-package! vhdl-ext
  :after vhdl-mode
  :hook
  ((vhdl-mode . vhdl-ext-mode)
   (vhdl-mode . paul/vhdl-mode-setup)
   (vhdl-mode . lsp-deferred))   ;; <- entscheidend
  :init
  (setq vhdl-ext-feature-list
        '(font-lock
          xref
          capf
          hierarchy
          flycheck
          beautify
          navigation
          compilation
          template
          imenu
          which-func
          hideshow
          time-stamp
          ports))
  :config
  (vhdl-ext-mode-setup))

(after! lsp-mode
  (setq lsp-vhdl-server 'vhdl-ls
        lsp-vhdl-server-path "/Users/paulkronegger/.local/bin/vhdl_ls_wrapper"
        lsp-log-io t
        lsp-auto-guess-root t))  ;; <- hilft bei Root-Erkennung

(after! projectile
  ;; damit Doom/Projectile dein VHDL-Projekt korrekt als Projekt erkennt
  (add-to-list 'projectile-project-root-files "vhdl_ls.toml"))

(defun paul/vhdl-format-buffer ()
  (when (derived-mode-p 'vhdl-mode)
    (vhdl-beautify-buffer)))

(defun paul/vhdl-mode-setup ()
  (setq-local vhdl-modify-date-on-saving nil)

  (when (bound-and-true-p apheleia-mode)
    (apheleia-mode -1))

  (add-hook 'before-save-hook #'paul/vhdl-format-buffer nil t))

(after! format
  (setq +format-on-save-enabled-modes
        '(not emacs-lisp-mode
          sql-mode
          tex-mode
          latex-mode
          vhdl-mode)))


;; undo
(setq undo-limit 8000000
      undo-strong-limit 12000000
      undo-outer-limit 120000000)

;; tabs
(after! centaur-tabs
  (map! :n "gt" #'centaur-tabs-forward
        :n "gT" #'centaur-tabs-backward
        :n "L"  #'centaur-tabs-forward
        :n "H"  #'centaur-tabs-backward))

;; scrolling with j, k, C-U and C-D
(setq scroll-margin 5
      scroll-conservatively 101
      scroll-step 1
      scroll-preserve-screen-position t)


;; rename file
(map! "C-x C-r" #'rename-file)

;; save file
(map! "C-s C-s" #'save-buffer)

;; snippests
(after! yasnippet
  (yas-global-mode 1))

;; better looking neotree
(map! :leader
      :n "e" #'neotree-toggle)
(after! neotree
  (setq neo-theme 'icons
        neo-window-width 35
        neo-smart-open t
        neo-show-hidden-files t
        neo-window-fixed-size nil
        neo-vc-integration '(face)
        all-the-icons-scale-factor 0.95)

  (add-hook 'neo-after-create-hook
            (lambda (&rest _)
              (setq-local line-spacing 0.2))))

;; cmake
(add-hook 'cmake-mode-local-vars-hook #'lsp!)

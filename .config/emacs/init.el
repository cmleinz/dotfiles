;; AUTHOR: Caleb Leinz
;; EMACS_VERSION: 28.1

;; The default is 800 kilobytes.  Measured in bytes.
(setq gc-cons-threshold (* 50 1000 1000))

;; Profile emacs startup
(add-hook 'emacs-startup-hook
          (lambda ()
            (message "*** Emacs loaded in %s with %d garbage collections."
                     (format "%.2f seconds"
                             (float-time
                              (time-subtract after-init-time before-init-time)))
                     gcs-done)))

;; Initialize package sources
(require 'package)

(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("melpa-stable" . "https://stable.melpa.org/packages/")
                         ("org" . "https://orgmode.org/elpa/")
                         ("elpa" . "https://elpa.gnu.org/packages/")))

(package-initialize)
(unless package-archive-contents
 (package-refresh-contents))

;; Ensure we have use-package setup
(require 'use-package)
(setq use-package-always-ensure t)

;; Disable splashscreen
(setq inhibit-startup-message t)

;; Make Emacs more minimal
(menu-bar-mode -1) ; Disable menubar
(tool-bar-mode -1) ; Disable toolbar
(scroll-bar-mode -1) ; Disable scrollbar

;; Enable global line numbers
(setq display-line-numbers-type 'relative)
(global-display-line-numbers-mode 1)

(save-place-mode 1) 

;; Set font to Fira Code
(set-face-attribute 'default nil :font "Fira Code Retina" :height 110)

;; Use the Iosvkem theme from the doom themese package
(use-package doom-themes
  :ensure t
  :config
  ;; Global settings (defaults)
  (setq doom-themes-enable-bold t    ; if nil, bold is universally disabled
        doom-themes-enable-italic t) ; if nil, italics is universally disabled
  (load-theme 'doom-Iosvkem t)

  ;; Enable flashing mode-line on errors
  (doom-themes-visual-bell-config)
  ;; Enable custom neotree theme (all-the-icons must be installed!)
  (doom-themes-neotree-config)
  ;; or for treemacs users
  (setq doom-themes-treemacs-theme "doom-atom") ; use "doom-colors" for less minimal icon theme
  (doom-themes-treemacs-config)
  ;; Corrects (and improves) org-mode's native fontification.
  (doom-themes-org-config))

;; Use swiper for supercharged searching
(use-package swiper
  :ensure t)

;; Use counsel
(use-package counsel
  :bind (("M-x" . counsel-M-x)
         ("C-x b" . counsel-ibuffer)
         ("C-x C-f" . counsel-find-file)
         :map minibuffer-local-map
         ("C-r" . 'counsel-minibuffer-history)))

;; Use Ivy for all sorts of useful autocompletion
(use-package ivy
  :diminish
  :bind (("C-s" . swiper)
         :map ivy-minibuffer-map
         ("TAB" . ivy-alt-done)	
         ("C-l" . ivy-alt-done)
         ("C-j" . ivy-next-line)
         ("C-k" . ivy-previous-line)
         :map ivy-switch-buffer-map
         ("C-k" . ivy-previous-line)
         ("C-l" . ivy-done)
         ("C-d" . ivy-switch-buffer-kill)
         :map ivy-reverse-i-search-map
         ("C-k" . ivy-previous-line)
         ("C-d" . ivy-reverse-i-search-kill))
  :config
  (ivy-mode 1))

;; Enable the doom modeline
(use-package doom-modeline
  :ensure t
  :init (doom-modeline-mode 1)
  :custom ((doom-modeline-height 15)))

;; Use the general package to setup space bindings
(use-package general
  :config
  (general-evil-setup t)
  (general-create-definer cl/leader-keys
    :keymaps '(normal insert visual emacs)
    :prefix "SPC"
    :global-prefix "C-SPC")
 
  (general-create-definer cl/leader-keys-files
    :keymaps '(normal emacs visual)
    :prefix "SPC f")

  (general-create-definer cl/leader-keys-git
    :keymaps '(normal emacs visual)
    :prefix "SPC g")

  (general-create-definer cl/leader-keys-win
    :keymaps '(normal emacs visual)
    :prefix "SPC w")

  ;; The most common function calls, typically bound to a prefex and a single key press
  (cl/leader-keys
    "t"  '(:ignore t :which-key "toggles")
    "tt" '(counsel-load-theme :which-key "choose theme")
    "b"  '(counsel-switch-buffer :which-key "switch buffer")
    "o"  '(other-window :which-key "switch window")
    "s"  '(save-buffer :which-key "save file")
    "c"  '(centaur-tabs-mode :which-key "display centaur tabs")
    "rr" '((lambda () (interactive) (load-file "~/.config/emacs/init.el")) :which-key "reload init.el")
    "re" '((lambda () (interactive) (find-file "~/.config/emacs/init.el")) :which-key "open init.el")
    "d"  '(treemacs :which-key "treemacs toggle")
    )
  
  (cl/leader-keys-files
    "f"  '(counsel-find-file :which-key "find file")
    "d"  '(treemacs-find-file :which-key "treemacs find file")
    )
  
  (cl/leader-keys-git
    "s"  '(magit-status :which-key "display magit status")
    )

  (cl/leader-keys-win
   "d"  '(delete-window :which-key "close current window")
   "a"  '(delete-other-windows :which-key "close all other windows")
   "/"  '(split-window-below :which-key "split window horizontally")
   "s"  '(split-window-right :which-key "split window vertically")
   )
  )

;; Enable rainbow-delimiters
(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

;; Enable rainbow mode in css files
(use-package rainbow-mode
  :hook ((css-mode-hook . rainbow-mode)
	 (html-mode-hook . rainbow-mode)
	 (scss-mode-hook . rainbow-mode)))

;; Enable autopairs in prog hook
(use-package smartparens
  :hook (prog-hook . smartparens-mode))

(use-package evil-smartparens
  :hook (smartparens-mode . evil-smartparens-mode))

(use-package pdf-tools
  :magic ("%PDF" . pdf-view-mode))

;; Setup Evil-mode, because it's really good
(use-package evil
  :init
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  (setq evil-want-C-u-scroll t)
  (setq evil-want-C-i-jump nil)
  :config
  (evil-mode 1)
  (define-key evil-insert-state-map (kbd "C-g") 'evil-normal-state)
  (define-key evil-insert-state-map (kbd "C-h") 'evil-delete-backward-char-and-join)

  ;; Use visual line motions even outside of visual-line-mode buffers
  (evil-global-set-key 'motion "j" 'evil-next-visual-line)
  (evil-global-set-key 'motion "k" 'evil-previous-visual-line)

  (evil-set-initial-state 'messages-buffer-mode 'normal)
  (evil-set-initial-state 'dashboard-mode 'normal))

(use-package evil-collection
  :after evil
  :config
  (evil-collection-init))

(defun cl/org-mode-setup ()
  (visual-line-mode 1)
  (flyspell-mode 1))

(use-package org
  :hook (org-mode . efs/org-mode-setup)
  :config

    (use-package evil-org
      :ensure t
      :after (evil org)
      :config
      (add-hook 'org-mode-hook 'evil-org-mode)
      (add-hook 'evil-org-mode-hook
      		(lambda ()
      		(evil-org-set-key-theme '(navigation insert textobjects additional calendar todo))))
      (require 'evil-org-agenda)
      (evil-org-agenda-set-keys))

  (use-package org-bullets
    :after org
    :hook (org-mode . org-bullets-mode))
  
  (setq org-agenda-start-with-log-mode t)
  (setq org-log-done 'time)
  (setq org-log-into-drawer t)
  (setq org-startup-indented t)

  ;; Set Org-Mode TODO keywords
  (setq org-todo-keywords
	'((sequence "TODO(t)" "PROG(p)" "PROJ(j)" "SENT(s)" "|" "DONE(d)" "CANC(c)" "PASS(a)")))
  ;; Set Org-Mode TODO state colors
  (setq org-todo-keyword-faces
	'(("TODO" . "#ff5555") ("PROG" . "#ffb86c") ("PROJ" . "#8be9fd") ("SENT" . "#ff79c6")
          ("DONE" . "#50fa7b") ("CANC" . "#a4fcba") ("PASS" . "#44475a")))
 
  (setq org-agenda-files
	'(("~/Nextcloud/Org/Todo.org")("~/Nextcloud/Ord/Life.org")))
 
  (setq org-refile-targets
    '(("~/Nextcloud/Org/Archive.org" :maxlevel . 1)))

  ;; Save Org buffers after refiling!
  (advice-add 'org-refile :after 'org-save-all-org-buffers))

 ;; ----------------DEVELOPMENT SETUP----------------
(use-package smartparens
  :hook (prog-mode . smartparens-mode))

(use-package centaur-tabs
  :demand
  :config
  (setq centaur-tabs-set-icons t
	centaur-tabs-show-navigation-buttons t
	centaur-tabs-height 32
	centaur-tabs-set-modified-marker t)
  (centaur-tabs-change-fonts "Fira Code Retina" 120))

(use-package treemacs
  :init (setq treemacs-show-hidden-files nil)
  :config
  (setq treemacs-default-visit-action 'treemacs-visit-node-close-treemacs)
  (use-package treemacs-evil))

;; Use yasnippets
(use-package yasnippet
  :ensure
  :config
  (setq yas-snippet-dirs
	'("~/.config/emacs/snippets/"))
  (yas-reload-all)
  (yas-global-mode)
  (add-hook 'prog-mode-hook 'yas-minor-mode)
  (add-hook 'text-mode-hook 'yas-minor-mode)
  (use-package yasnippet-snippets))

;; Flycheck conducts on-the-fly syntax checking
(use-package flycheck
  :ensure t
  :init (global-flycheck-mode))

;; Allow for smooth scrolling, line-by-line at the end of the view 
(use-package smooth-scrolling
  :init (smooth-scrolling-mode 1)
  :config (setq smooth-scrolling-margin 5))

(use-package magit
  :init
  (message "Loading Magit!")
  :config
  (message "Loaded Magit!")
  :bind (("C-x g" . magit-status)
         ("C-x C-g" . magit-status)))
;; ----------------PYTHON SETUP----------------
;; Elpy is the basic framework which provides things like
;; autocompletion, error checking, building, etc.
(use-package elpy
  :init (add-hook 'python-mode-hook #'elpy-enable)
  :config
  (setq elpy-rpc-python-command "python3")
  (add-hook 'elpy-mode-hook 'ligature-mode)
  )

;; Code formatting on save with black
(use-package blacken
  :init (add-hook 'elpy-mode-hook 'blacken-mode))

;;
;; ----------------RUST SETUP----------------
(use-package rustic
  :ensure
  :bind (:map rustic-mode-map
              ("M-j" . lsp-ui-imenu)
              ("M-?" . lsp-find-references)
              ("C-c C-c l" . flycheck-list-errors)
              ("C-c C-c a" . lsp-execute-code-action)
              ("C-c C-c r" . lsp-rename)
              ("C-c C-c q" . lsp-workspace-restart)
              ("C-c C-c Q" . lsp-workspace-shutdown)
              ("C-c C-c s" . lsp-rust-analyzer-status))
  :config
  ;; uncomment for less flashiness
  ;; (setq lsp-eldoc-hook nil)
  ;; (setq lsp-enable-symbol-highlighting nil)
  ;; (setq lsp-signature-auto-activate nil)

  ;; comment to disable rustfmt on save
  (setq rustic-format-on-save t)
  (add-hook 'rustic-mode-hook 'rk/rustic-mode-hook))

(defun rk/rustic-mode-hook ()
  ;; so that run C-c C-c C-r works without having to confirm, but don't try to
  ;; save rust buffers that are not file visiting. Once
  ;; https://github.com/brotzeit/rustic/issues/253 has been resolved this should
  ;; no longer be necessary.
  (when buffer-file-name
    (setq-local buffer-save-without-query t)))

(use-package lsp-mode
  :ensure
  :commands lsp
  :custom
  ;; what to use when checking on-save. "check" is default, I prefer clippy
  (lsp-rust-analyzer-cargo-watch-command "clippy")
  (lsp-eldoc-render-all t)
  (lsp-idle-delay 0.6)
  (lsp-rust-analyzer-server-display-inlay-hints t)
  (lsp-rust-analyzer-display-lifetime-elision-hints-enable "skip_trivial")
  (lsp-rust-analyzer-display-chaining-hints t)
  (lsp-rust-analyzer-display-lifetime-elision-hints-use-parameter-names nil)
  (lsp-rust-analyzer-display-closure-return-type-hints t)
  (lsp-rust-analyzer-display-parameter-hints nil)
  (lsp-rust-analyzer-display-reborrow-hints nil)
  :config
  (add-hook 'lsp-mode-hook 'lsp-ui-mode))
(use-package lsp-ui
  :ensure
  :commands lsp-ui-mode
  :custom
  (lsp-ui-peek-always-show t)
  (lsp-ui-sideline-show-hover t)
  (lsp-ui-doc-enable nil))
(use-package lsp-ivy :commands lsp-ivy-workspace-symbol)

(use-package company
  :ensure
  :custom
  (company-idle-delay 0.5) ;; how long to wait until popup
  ;; (company-begin-commands nil) ;; uncomment to disable popup
  :bind
  (:map company-active-map
	      ("C-n". company-select-next)
	      ("C-p". company-select-previous)
	      ("M-<". company-select-first)
	      ("M->". company-select-last))
  :config
  (use-package company-jedi)
)
;;; 

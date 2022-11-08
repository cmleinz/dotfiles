(require 'package)

(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("org" . "https://orgmode.org/elpa/")
                         ("elpa" . "https://elpa.gnu.org/packages/")))

;; (unless package-archive-contents
;;   (package-refresh-contents))

;; Initialize use-package on non-Linux platforms
(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)

(setq vc-follow-symlinks nil)
;; Don't ask about org mode config files
(setq org-confirm-babel-evaluate nil)

(org-babel-load-file (expand-file-name "~/.config/emacs/config.org"))
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(projectile dashboard yasnippet-snippets which-key vterm use-package tree-sitter-langs smartparens rustic rainbow-mode rainbow-delimiters pdf-tools org-transclusion org-bullets minions magit lsp-ui lsp-ivy general flycheck fira-code-mode evil-org evil-nerd-commenter evil-collection elpy eglot doom-themes doom-modeline diff-hl counsel company-jedi centaur-tabs blacken autothemer)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   (quote
    (ag hydra use-package dumb-jump rspec-mode rubocop coffee-mode yaml-mode inf-ruby scss-mode markdown-mode ido-vertical-mode smartscan company-tabnine company exec-path-from-shell zop-to-char zenburn-theme which-key volatile-highlights undo-tree super-save smartrep smartparens operate-on-number move-text magit projectile imenu-anywhere hl-todo guru-mode gitignore-mode gitconfig-mode git-timemachine gist flycheck expand-region epl editorconfig easy-kill diminish diff-hl discover-my-major crux browse-kill-ring beacon anzu ace-window)))
 '(safe-local-variable-values (quote ((flycheck-disabled-checkers emacs-lisp-checkdoc)))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

;; ido is for fuzzy matching
(setq ido-enable-flex-matching t)
(setq ido-everywhere t)
(ido-mode 1)

;; Tabnine stuff
(add-hook 'after-init-hook 'global-company-mode)
(require 'company-tabnine)
(add-to-list 'company-backends #'company-tabnine)
;; Trigger completion immediately.
(setq company-idle-delay 0)

;; Number the candidates (use M-1, M-2 etc to select completions).
(setq company-show-numbers t)

;; Use the tab-and-go frontend.
;; Allows TAB to select and complete at the same time.
(company-tng-configure-default)
(setq company-frontends
	'(company-tng-frontend
		 company-pseudo-tooltip-frontend
		 company-echo-metadata-frontend))

;; Allow hash to be entered
(global-set-key (kbd "M-3") '(lambda () (interactive) (insert "#")))

(global-set-key (kbd "<M-up>") 'shrink-window)
(global-set-key (kbd "<M-down>") 'enlarge-window)
(global-set-key (kbd "<M-left>") 'shrink-window-horizontally)
(global-set-key (kbd "<M-right>") 'enlarge-window-horizontally)

(add-hook 'ruby-mode-hook #'rubocop-mode)

(show-paren-mode 1)
(global-smartscan-mode 1)


 ;; I want this for dired-jump
(require 'dired-x)

;; Nice listing
(setq find-ls-option '("-print0 | xargs -0 ls -alhd" . ""))

;; Always copy/delete recursively
(setq dired-recursive-copies (quote always))
(setq dired-recursive-deletes (quote top))

;; Auto refresh dired, but be quiet about it
(setq auto-revert-verbose nil)

;; Hide some files
(setq dired-omit-files "^\\..*$\\|^\\.\\.$")
(setq dired-omit-mode t)

;; List directories first
(defun sof/dired-sort ()
  "Dired sort hook to list directories first."
  (save-excursion
   (let (buffer-read-only)
     (forward-line 2) ;; beyond dir. header
     (sort-regexp-fields t "^.*$" "[ ]*." (point) (point-max))))
  (and (featurep 'xemacs)
       (fboundp 'dired-insert-set-properties)
       (dired-insert-set-properties (point-min) (point-max)))
  (set-buffer-modified-p nil))

(add-hook 'dired-after-readin-hook 'sof/dired-sort)

;; Automatically create missing directories when creating new files
(defun my-create-non-existent-directory ()
      (let ((parent-directory (file-name-directory buffer-file-name)))
        (when (and (not (file-exists-p parent-directory))
                   (y-or-n-p (format "Directory `%s' does not exist! Create it?" parent-directory)))
          (make-directory parent-directory t))))
(add-to-list 'find-file-not-found-functions #'my-create-non-existent-directory)

;; Use ls from emacs
(when (eq system-type 'darwin)
  (require 'ls-lisp)
  (setq ls-lisp-use-insert-directory-program nil))

;; Changing the way M-< and M-> work in dired
;; Instead of taking me to the very beginning or very end, they now take me to the first or last file.
(defun dired-back-to-top ()
  (interactive)
  (beginning-of-buffer)
  (next-line 2))

(define-key dired-mode-map
  (vector 'remap 'beginning-of-buffer) 'dired-back-to-top)

(defun dired-jump-to-bottom ()
  (interactive)
  (end-of-buffer)
  (next-line -1))

(define-key dired-mode-map
  (vector 'remap 'end-of-buffer) 'dired-jump-to-bottom)

;; C-a is nicer in dired if it moves back to start of files
(defun dired-back-to-start-of-files ()
  (interactive)
  (backward-char (- (current-column) 2)))

(define-key dired-mode-map (kbd "C-a") 'dired-back-to-start-of-files)


(require 'ido)
(ido-mode 1)

;; Display results vertically
(require 'ido-vertical-mode)
(ido-vertical-mode)

(setq ido-enable-prefix nil
      ido-enable-flex-matching t
      ido-case-fold t ;; ignore case
      ido-auto-merge-work-directories-length -1 ;; disable auto-merge (it's confusing)
      ido-create-new-buffer 'always ;; create new files easily
      ido-use-filename-at-point nil ;; don't try to be smart about what I want
      )

;; I like visual matching (colors)
(setq ido-use-faces t)

;; Ido buffer intuitive navigation
(add-hook 'ido-setup-hook '(lambda ()
                             (define-key ido-completion-map "\C-h" 'ido-delete-backward-updir)
                             (define-key ido-completion-map "\C-n" 'ido-next-match)
                             (define-key ido-completion-map "\C-f" 'ido-next-match)
                             (define-key ido-completion-map "\C-p" 'ido-prev-match)
                             (define-key ido-completion-map "\C-b" 'ido-prev-match)
                             (define-key ido-completion-map " " 'ido-exit-minibuffer)
                             ))

;; Use C-w to go back up a dir to better match normal usage of C-w
;; - insert current file name with C-x C-w instead.
(define-key ido-file-completion-map (kbd "C-w") 'ido-delete-backward-updir)
(define-key ido-file-completion-map (kbd "C-x C-w") 'ido-copy-current-file-name)

;; disable auto searching for files unless called explicitly
(setq ido-auto-merge-delay-time 99999)

;; Ignore .DS_Store files with ido mode
(add-to-list 'ido-ignore-files "\\.DS_Store")

(setq ruby-indent-level 2)
(add-hook 'ruby-mode-hook #'rubocop-mode)

;; to setup tabs
(setq indent-tabs-mode nil)
(setq-default indent-tabs-mode nil)

; ;; save files in user dir
; (setq auto-save-file-name-transforms
; 	`((".*" ,(concat user-emacs-directory "auto-save/") t)))

;; show whitespaces
(require 'whitespace)
(setq whitespace-line-column 120) ;; limit line length
(setq whitespace-style '(spaces tabs newline space-mark tab-mark newline-mark face lines-tail))
(setq whitespace-display-mappings
	;; all numbers are Unicode codepoint in decimal. e.g. (insert-char 182 1)
	'(
		 (space-mark nil) ; 32 SPACE, 183 MIDDLE DOT
		 (newline-mark 10 [172 10]) ; 10 LINE FEED
		 (tab-mark 9 [183 9] [92 9]) ; 9 TAB, MIDDLE DOT
		 ))
(setq whitespace-global-modes '(not org-mode web-mode "Web" emacs-lisp-mode))
(global-whitespace-mode)

;; auto ident after new line
; (when (fboundp 'electric-indent-mode) (electric-indent-mode -1))

(when (version<= "26.0.50" emacs-version )
  (global-display-line-numbers-mode))

; this messes up with my indentation
(require 'editorconfig)
(editorconfig-mode -1)

;; bidning pry stuff
(add-hook 'after-init-hook 'inf-ruby-switch-setup)

(use-package dumb-jump
             :bind (("M-g o" . dumb-jump-go-other-window)
                    ("M-g j" . dumb-jump-go)
                    ("M-g i" . dumb-jump-go-prompt)
                    ("M-g x" . dumb-jump-go-prefer-external)
                    ("M-g z" . dumb-jump-go-prefer-external-other-window))
             :config (setq dumb-jump-selector 'ivy) ;; (setq dumb-jump-selector 'helm)
             :ensure)

(dumb-jump-mode)

;; Set custom file to be somewhere else.
(setq custom-file "~/.emacs.d/custom.el")
(load custom-file)

;; Include packages stored locally.
(add-to-list 'load-path "~/.emacs.d/local-packages")

(setq insert-directory-program "gls")

;; Avoid asking confirmation when killing a buffer with a process.
(setq kill-buffer-query-functions nil)

;; Don't show warnings when doing async native com.
(setq native-comp-async-report-warnings-errors nil)

(require 'package)

;; Specify repositories.
(setq package-archives '(("melpa" . "https://melpa.org/packages/")
			 ("org" . "https://orgmode.org/elpa/")
			 ("elpa" . "https://elpa.gnu.org/packages/")))

(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

;; Install use-package if not present
(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(require 'use-package)
;; Avoid using :ensure t on every package installation.
(setq use-package-always-ensure t)

(setq inhibit-startup-message t)

;; Always start as a full frame.
(add-to-list 'default-frame-alist '(fullscreen . maximized))

;; Set right command key to meta.
(setq ns-right-command-modifier 'meta)

(scroll-bar-mode -1) ;; Disable visible scrollbar.
(tool-bar-mode -1) ;; Disable the toolbar.
(tooltip-mode -1) ;; Disable tooltips.
(set-fringe-mode 10) ; Breathing room for windows.

;; Set up the visible bell.
(setq visible-bell nil
      ring-bell-function 'flash-mode-line)
(defun flash-mode-line ()
  (invert-face 'mode-line)
  (run-with-timer 0.1 nil #'invert-face 'mode-line))

;; Do not center cursor after scroll.
(setq scroll-conservatively 101)

(set-face-attribute 'default nil :font "Fira Code Retina")

;; Enable ligatures for fonts that allow it (Fira Code does).
;; The ligature package is locally installed.

;; Ligatures cause problems with python, I could find out which ones do and avoid them.

;; (use-package ligature
;;   :ensure nil
;;   :config
;;   ;; Enable the "www" ligature in every possible major mode
;;   (ligature-set-ligatures 't '("www"))
;;   ;; Enable traditional ligature support in eww-mode, if the
;;   ;; `variable-pitch' face supports it
;;   (ligature-set-ligatures 'eww-mode '("ff" "fi" "ffi"))
;;   ;; Enable all Cascadia Code ligatures in programming modes
;;   (ligature-set-ligatures '(prog-mode org-mode) ;; Be careful to not use the asterisk ligatures becase they interfere with org mode.
;; 			  '("www" "**/" "*>" "*/" "\\\\" "\\\\\\" "{-" "::"
;; 				       ":::" ":=" "!!" "!=" "!==" "-}" "-->" "->" "->>"
;; 				       "-<" "-<<" "-~" "#{" "#[" "##" "###" "####" "#(" "#?" "#_"
;; 				       "#_(" ".-" ".=" ".." "..<" "..." "?=" "??" ";;" "/*" "/**"
;; 				       "/=" "/==" "/>" "//" "///" "&&" "||" "||=" "|=" "|>" "^=" "$>"
;; 				       "++" "+++" "+>" "=:=" "==" "===" "==>" "=>" "=>>" "<="
;; 				       "=<<" "=/=" ">-" ">=" ">=>" ">>" ">>-" ">>=" ">>>" "<*"
;; 				       "<*>" "<|" "<|>" "<$" "<$>" "<!--" "<-" "<--" "<->" "<+"
;; 				       "<+>" "<=" "<==" "<=>" "<=<" "<>" "<<" "<<-" "<<=" "<<<"
;; 				       "<~" "<~~" "</" "</>" "~@" "~-" "~>" "~~" "~~>" "%%"))
;;   ;; Enables ligature checks globally in all buffers.  You can also do it
;;   ;; per mode with `ligature-mode'.
;;   (global-ligature-mode t))

;; Make ESC quit prompts.
(global-set-key (kbd "<escape>") 'keyboard-escape-quit) ;; Put with evil.

;; Setup leader key.
(use-package general
  :config
  ;; Create leader definer.
  (general-create-definer mariano/leader-keys
    :keymaps '(normal visual emacs) ; Where the prefix will work. Consider taking out insert mode if too annoying.
    :prefix "SPC"
    :gloabl-prefix "C-SPC")) ;; This prefix will work everywhere.

(defun mariano/switch-to-prev-visible-buffer ()
  "Switch to previously open buffer.
Repeated invocations toggle between the two most recently open buffers."
  (interactive)
  (switch-to-buffer (other-buffer (current-buffer) 1)))

;; Basic leader keys.
(mariano/leader-keys
  "s" 'save-buffer
  "SPC" '(mariano/switch-to-prev-visible-buffer :which-key "previous buffer"))

;; Makes the specified modes to start in emacs mode (no vim keybindings)
(defun mariano/evil-hook ()
  (dolist ( mode '(custom-mode
		   eshell-mode
		   term-mode))
    (add-to-list 'evil-emacs-state-modes mode)))

(use-package evil
  :init
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  ;; (setq evil-want-C-u-scroll t) ;; I may want it in the future.
  (setq evil-want-C-i-jump nil) ;; I have never used the jump functionality, turn it on if needed.
  ;; :hook (evil-mode . mariano/evil-hook) ;; Only set up when I find a need for this.
  :config
  (evil-mode 1)
  (define-key evil-insert-state-map (kbd "C-g") 'evil-normal-state)
  (define-key evil-insert-state-map (kbd "C-h") 'evil-delete-backward-char-and-join)

  ;; Allow navigation in wrwapped lines.
  ;; Deactivated because it causes dj to behave differently.
  ;; (evil-global-set-key 'motion "j" 'evil-next-visual-line)
  ;; (evil-global-set-key 'motion "k" 'evil-previous-visual-line)

  ;; Always start in normal mode in the messages buffer.
  (evil-set-initial-state 'messages-buffer-mode 'normal))

(use-package evil-collection
  :after evil
  :config
  (evil-collection-init))

(use-package key-chord
  :config
  (key-chord-mode 1)
  (key-chord-define evil-insert-state-map "kj" 'evil-normal-state)
  :custom
  (key-chord-two-keys-delay 0.3))

;; Setup hydra.
(use-package hydra)

;; Window size hydras.
(defhydra hydra-window-size (:timeout 4)
  "Window horizontal size"
  ("<" evil-window-decrease-width "decrease width")
  (">" evil-window-increase-width "increase width")
  ("+" evil-window-increase-height "increase height")
  ("-" evil-window-decrease-height "decrease height")
  ("f" nil "finished" :exit t))

(defun mariano/toggle-maximize-window () "Maximize buffer"
  (interactive)
  (if (= 1 (length (window-list)))
      (jump-to-register '_) 
    (progn
      (window-configuration-to-register '_)
      (delete-other-windows))))

;; Window leader keys.
(mariano/leader-keys
  "w" '(:ignore t :which-key "windows")
  "w-" '(split-window-below :which-key "split vertical")
  "w|" '(split-window-horizontally :which-key "split horizontal")
  "wj" '(evil-window-down :which-key "window below")
  "wk" '(evil-window-up :which-key "window above")
  "wh" '(evil-window-left :which-key "window left")
  "wl" '(evil-window-right :which-key "window right")
  "ws" '(hydra-window-size/body :which-key "window size")
  "wd" '(delete-window :which-key "delete current window")
  "wf" '(mariano/toggle-maximize-window :which-key "maximize window"))

;; Kill all buffers except the current one.
(defun kill-other-buffers ()
  "Kill all other buffers."
  (interactive)
  (mapc 'kill-buffer ;; Apply the command kill-buffer to all elements of the list.
        (delq (current-buffer) ;; Remove the current buffer from the list of to-be-removed.
              (cl-remove-if-not 'buffer-file-name (buffer-list))))) ;; Only remove file buffers.

(defun mariano/kill-buffer-and-window () 
  "Kills the current buffer. If there's more than one window and it is not the leftmost window, it also kills it." 
  (interactive) 
  (if (and (> (count-windows) 1) 
	   (window-left (selected-window))) 
	(kill-buffer-and-window)
    (kill-buffer)))


;; Buffer leader keys.
(mariano/leader-keys
  "b" '(:ignore t :which-key "buffers")
  "bs" '(counsel-switch-buffer :which-key "switch buffer")
  "bk" '(mariano/kill-buffer-and-window :which-key "kill buffer")
  "be" '(eval-buffer :which-key "eval buffer")
  "bO" '(kill-other-buffers :which-key "keep only the current buffer"))

;; Files leader keys.
(mariano/leader-keys
  "f" '(:ignore t :which-key "files")
  "ff" '(counsel-find-file :which-key "find file") ;; Consider replacing this with projectile find file.
  "fw" '(save-buffer :which-key "write file"))

;; Allows for the left option key to be bound to the native OSX behavior.
(setq ns-alternate-modifier 'none)
(setq ns-right-alternate-modifier 'meta)

(mariano/leader-keys
  "r" '(:ignore t :which-key "bookmarks")
  "rl" '(bookmark-bmenu-list :which-key "list bookmarks")
  "rc" '(bookmark-set :which-key "create at this location"))

(use-package doom-themes
  :config
  ;; Global settings (defaults)
  (setq doom-themes-enable-bold t    ; if nil, bold is universally disabled
        doom-themes-enable-italic t) ; if nil, italics is universally disabled
  (load-theme 'doom-palenight t)

  ;; Enable flashing mode-line on errors
  ;; (doom-themes-visual-bell-config)

  ;; Enable custom neotree theme (all-the-icons must be installed!)
  ;; (doom-themes-neotree-config)

  ;; Corrects (and improves) org-mode's native fontification.
  (doom-themes-org-config))

(use-package doom-modeline
  :init (doom-modeline-mode 1))

;; Show completion after pressing a prefix.
(use-package which-key
  :diminish
  :init (which-key-mode)
  :config
  (setq which-key-idle-delay 0.3))

(use-package swiper)

;; Use counsel for M-x when switching buffers and when opening files.
(use-package counsel
  :bind (("M-x" . counsel-M-x)
	 ("C-x b" . counsel-ibuffer)
	 ("C-x C-f" . counsel-find-file)
	 :map minibuffer-local-map ; TODO: not exactly sure what this is for, investigate.
	 ("C-r" . 'counsel-minibuffer-history)))

(use-package smex) ;; So counsel-M-x can show history.

(use-package ivy
  :diminish
  :bind (("C-s" . swiper)                 ; Change the default global command to swiper.
	 :map ivy-minibuffer-map          ; Bindings for mminibuffer (prompts)
	 ("TAB" . ivy-alt-done)
	 ("C-j" . ivy-next-line)
	 ("C-k" . ivy-previous-line)
	 :map ivy-switch-buffer-map       ; Bindings for switching buffers (C-x C-b)
	 ("C-k" . ivy-previous-line)
	 ("C-l" . ivy-done)               ; Test out, change if not comfortable.
	 ("C-d" . ivy-switch-buffer-kill) ; Test, out change if not comfortable.
					  ; Maybe add a next line bind.
	 :map ivy-reverse-i-search-map        ; Binding for reverse search (history search)
	 ("C-k" . ivy-previous-line)
	 ("C-d" . ivy-reverse-i-searck-kill)) ; Test out, change if not comfortable.
  :config
  (ivy-mode 1)) ; Activating ivy mode and its bindings.

;; Show description and keybindings for commands when using counsel-M-x
(use-package ivy-rich
  :init
  (ivy-rich-mode))

;; Show more information in help pages.
(use-package helpful
 :init
 (setq counsel-describe-function-function #'helpful-callable)
 (setq counsel-describe-variable-function #'helpful-variable)
 :bind
 ([remap describe-function] . counsel-describe-function)
 ([remap describe-command] . helpful-command)
 ([remap describe-variable] . counsel-describe-variable)
 ([remap describe-key] . helpful-key))

;; Display line numbers
(column-number-mode)			; Show colum in modeline.
(global-display-line-numbers-mode t)

;; Disable line numbers for certain modes.
(dolist (mode '(org-mode-hook vterm-mode-hook term-mode-hook shell-mode-hook eshell-mode-hook)) 
  (add-hook mode (lambda () 
		   (display-line-numbers-mode 0))))

;; Always use relative when using line numbers mode. Except on excluded modes.
(add-hook 'display-line-numbers-mode-hook (lambda () 
					    (unless (memq major-mode '(fundamental-mode org-mode
											vterm-mode
											term-mode
											shell-mode
											eshell-mode)) 
					      (setq display-line-numbers 'relative))))

(use-package hl-todo
  :config (global-hl-todo-mode))

(defun mariano/org-font-setup ()
    ;; Set faces for heading levels
    (dolist (face '((org-level-1 . 1.2)
		    (org-level-2 . 1.1)
		    (org-level-3 . 1.05)
		    (org-level-4 . 1.0)
		    (org-level-5 . 1.1)
		    (org-level-6 . 1.1)
		    (org-level-7 . 1.1)
		    (org-level-8 . 1.1)))
	    (set-face-attribute (car face) nil :font "Arial" :weight 'regular :height (cdr face))) ;; Try some other variable width font for titles.

    ;; Replace list hyphen with dot
    (font-lock-add-keywords 'org-mode
			    '(("^ *\\([-]\\) "
			    (0 (prog1 () (compose-region (match-beginning 1) (match-end 1) "•")))))))

(defun mariano/org-mode-setup () 
  (org-indent-mode)
  ;; (variable-pitch-mode) ;; Use in case I want to have Arial or any other font in my text.
  (visual-line-mode 1) 
  (setq evil-auto-indent nil))

;; Org mode.
(use-package org
  :hook (org-mode . mariano/org-mode-setup)
  :config
  (setq org-hide-emphasis-markers t)
  (setq org-ellipsis " ↩")
  (setq org-agenda-files
	'("~/Documents/Org/Tasks.org"
	  "~/Documents/school_notes"
	  "~/Documents/Org/Birthdays.org")) ;; Add org files to be considered for the agenda.

  ;; Tags that org will recognize as typically used.
  (setq org-tag-alist
	'((:startgroup)
	  ("@personal" . ?P)
	  ("@home" . ?H)
	  ("@work" . ?W)
	  (:endgroup)
	  ("planning" . ?p)
	  ("note" . ?n)
	  ("idea" . ?i)))

  ;; Add the archive file as a retarget.
  (setq org-refile-targets
	'(("Archive.org" :maxlevel . 1)
	  ("Tasks.org" :maxlevel . 1)))

  ;; Save all org buffers after a refiling.
  (advice-add 'org-refile :after 'org-save-all-org-buffers)

  (setq org-capture-templates
    `(("t" "Tasks / Projects")
      ("tl" "Task with link" entry (file+olp "~/Documents/Org/Tasks.org" "Inbox")
       "* TODO %?\n  %U\n  %a\n  %i" :empty-lines 1)
      ("tt" "Task" entry (file+olp "~/Documents/Org/Tasks.org" "Inbox")
       "* TODO %?\n  %U\n  %i" :empty-lines 1)))

  (setq org-agenda-start-with-log-mode t) ;; Show a progress log when opening agenda.
  (setq org-log-done 'time) ;; Add a timestamp to tasks when they're marked as done.
  (setq org-log-into-drawer t) ;; INvestigate if this doesn't work.
  
  ;; Make indentation behave correctly in source blocks.
  (setq org-src-preserve-indentation nil
      org-edit-src-content-indentation 0)
  (mariano/org-font-setup))

(defun mariano/openTasks ()
  "Open the tasks file"
  (interactive)
  (find-file "~/Documents/Org/Tasks.org"))

;; Org agenda leader keys.
(mariano/leader-keys
  "a" '(:ignore t :which-key "org agenda")
  "aa" '(org-agenda :which-key "agenda menu")
  "ac" '(org-agenda-list :which-key "calendar")
  "at" '(mariano/openTasks :which-key "tasks"))

;; Org leader keys
(mariano/leader-keys
  "o" '(:ignore t :which-key "org")
  "oc" '((lambda () (interactive) (org-capture)) :which-key "capture tasks"))

;; Allow using j and k to navigate lines in org-agenda-mode.
(add-hook 'org-agenda-mode-hook (lambda () (progn
					    (define-key org-agenda-mode-map "j" 'evil-next-line)
					    (define-key org-agenda-mode-map "k" 'evil-previous-line)))) ;; Not so sure if needed.

(use-package org-bullets
  :after org
  :hook (org-mode . org-bullets-mode)
  :custom
  (org-bullets-bullet-list '("◉" "○" "●" "○" "●" "○" "●")))

(defun mariano/org-mode-visual-fill ()
  (setq fill-column 150) ;; Make fill-column consistent with the column width.
  (setq visual-fill-column-width 150
        visual-fill-column-center-text t)
  (visual-fill-column-mode 1)
  (auto-fill-mode))

(use-package visual-fill-column
  :hook (org-mode . mariano/org-mode-visual-fill))

(org-babel-do-load-languages
 'org-babel-load-languages
 '((emacs-lisp . t)
   (python . t)))

(setq org-confirm-babel-evaluate nil)

;; Automatically tangle Config.org when we save it.
(defun mariano/org-babel-tangle-config ()
  (when (string-equal (buffer-file-name)
		      (expand-file-name "~/dev/conf/emacs_configuration/Config.org"))
    ;; Dynamic scoping, investigate what this is.
    (let ((org-confirm-babel-evaluate nil))
      (org-babel-tangle))))

(add-hook 'org-mode-hook (lambda () (add-hook 'after-save-hook #'mariano/org-babel-tangle-config)))

(require 'org-tempo)

(add-to-list 'org-structure-template-alist '("el" . "src emacs-lisp")) ;; Emacs lisp source block.
(add-to-list 'org-structure-template-alist '("py" . "src python")) ;; Python lisp source block.

(use-package evil-nerd-commenter
  :bind ("M-/" . evilnc-comment-or-uncomment-lines))

(defun mariano/lsp-mode-setup ()
  ;; Show breadcrumb headbar.
  (setq lsp-headerline-breadcrumb-segments '(path-up-to-project file symbols)) ;; Turn off symbols if too annoying.
  (lsp-headerline-breadcrumb-mode))

(use-package lsp-mode
  :commands (lsp lsp-deferred) ;; Commands that activate the package.
  :hook (lsp-mode . mariano/lsp-mode-setup)
  :init
  (setq lsp-keymap-prefix "C-c l") ;; Put all lsp commands under C-c l
  (setq lsp-enable-snippet nil)
  :config
  (lsp-enable-which-key-integration t))

;; LSP leader keys

(mariano/leader-keys
  "l" '(:ignore t :which-key "LSP mode")
  "lg" '(:ignore t :which-key "goto")
  "lgd" '(lsp-find-definition :which-key "go to definition")
  "lgi" '(lsp-find-implementation :which-key "find implementation")
  "lgr" '(lsp-find-references :which-key "find references")
  "lr" '(:ignore t :which-key "refactor")
  "lrr" '(lsp-rename :which-key "rename")
)

(use-package lsp-ui
  :hook (lsp-mode . lsp-ui-mode)
  :custom
  (lsp-ui-doc-position 'bottom)
  (lsp-ui-doc-include-signature t))

;; (use-package lsp-treemacs
;;   :after lsp)

(use-package lsp-ivy)

(use-package typescript-mode
  :mode "\\.ts\\'"
  :hook (typescript-mode . lsp-deferred) ;; Use lsp-deferred so the LS only starts when the buffer is fully opened.
  :config
  (setq typescript-indent-level 2))

(use-package 
  rjsx-mode 
  :mode "\\.js\\'" 
  :hook ((rjsx-mode . lsp-deferred) 
	       (rjsx-mode . origami-mode)) 
  :config (setq js-indent-level 2))

(use-package 
  lsp-python-ms
  :init (setq lsp-python-ms-executable
	      "/Users/marianouvalle/dev/tools/python-language-server/output/bin/Release/osx-x64/publish/Microsoft.Python.LanguageServer"))

;; Start lsp only after directory local variables are set.
;; This ensures that the correct interpreter is used when .dir-locals.el is present.
(add-hook 'hack-local-variables-hook (lambda () 
				       (when (derived-mode-p 'python-mode) 
					 (require 'lsp-python-ms) 
					 (lsp-deferred))))

;; Formatter.
(use-package python-black
  :demand t
  :after python)

;; Run black automatically on save.
(add-hook 'python-mode-hook (lambda ()
			      (python-black-on-save-mode)))

;; Use 4 spaces for the indent level.
(add-hook 'python-mode-hook (lambda () 
			      (progn
				 (setq python-guess-indent nil)
				 (setq python-indent-guess-indent-offset nil)
				 (setq python-indent 4)
				 (setq python-indent-offset 4))))

;; If used withing a project that was a virtualenv, use a .dir-locals.el to set the proper interpreter.
;; ((python-mode . ((python-shell-interpreter . "~/dev/6502/eeprom_programmer/venv/bin/python")
;; 		 (lsp-python-ms-python-executable . "~/dev/6502/eeprom_programmer/venv/bin/python"))))

(use-package yaml-mode
  :mode "\\.yml\\'")

(use-package go-mode
  :config
  (setq gofmt-command (concat (getenv "GOPATH") "/bin/goimports"))
  (add-hook 'before-save-hook 'gofmt-before-save))

(load "~/.emacs.d/local-packages/emacs-prisma-mode/prisma-mode.el")
(require 'prisma-mode)

(setq auto-mode-alist
      (cons '("\\.prisma$" . prisma-mode) auto-mode-alist))
(setq lsp-language-id-configuration
      (cons '("\\.prisma$" . "prisma") lsp-language-id-configuration))

(use-package elixir-mode
  :hook (elixir-mode . lsp-deferred)
  :init
  (add-to-list 'exec-path "/Users/marianouvalle/.config/nvim/lang-srvrs/elixir-ls"))

(add-hook 'elixir-mode-hook
	  (lambda () (add-hook 'before-save-hook 'lsp-format-buffer  nil 'local)))

(add-hook 'c-mode-hook
  (lambda () (lsp t)))

(add-hook 'c++-mode-hook
  (lambda () (lsp t)))

(defun mariano/company-select-first-and-complete ()
  "Selects the appropriate candidate in the company mode list and completes it."
  (interactive)
  ;; Select the first candidate if none is selected.
  (when (eq company-selection nil)
    (company-select-first))
  ;; Complete the selected candidate.
  (company-complete))

(use-package 
  company 
  :after lsp-mode		  ;; Load after lsp-mode
  :hook (lsp-mode . company-mode) ;; Run whenever lsp-mode is active.
  :bind (:map company-active-map
	      ("<tab>" . 'mariano/company-select-first-and-complete)) ;; When pressing tab, insert the first candidate. Default is cycle.
  (:map lsp-mode-map 
	("<tab>" . company-indent-or-complete-common)) ;; Activate if I want common completions in empty line.
  :custom (company-minimum-prefix-length 1) 
  (company-idle-delay 0.0))

;; Imporove the UI for company mode.
(use-package company-box
  :hook (company-mode . company-box-mode))

(use-package yasnippet
  :config
  (yas-global-mode 1))

(use-package projectile
  :diminish
  :config (projectile-mode)
  :bind-keymap
  ("C-c p" . projectile-command-map) ;; Put all the projectile comands under C-c p
  :init
  (when (file-directory-p "~/dev") ;; Setup ~/dev as my local code repository. It does not recurse down.
    (setq projectile-project-search-path '("~/dev")))
  (setq projectile-switch-project-action #'projectile-dired)) ;; This does not work with counsel-projectile installed, refer to https://github.com/ericdanan/counsel-projectile/issues/62

;; Projectile leader keys.

(mariano/leader-keys
  "p" '(:ignore t :which-key "Projectile")
  "pp" '(projectile-switch-project :which-key "switch project")
  "pf" '(projectile-find-file :which-key "find file in project")
  "ps" '(projectile-ripgrep :which-key "search in whole project"))

;; Extra ivy actions for projectile commands.
(use-package counsel-projectile
  :after projectile
  :config (counsel-projectile-mode))

(use-package magit)
;; :custom
;; (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1)) ;; Use this if diffing in a different window is annoying.

;; Leader keybindings for magit.
(mariano/leader-keys
  "g" '(:ignore t :which-key "magit")
  "gs" '(magit-status :which-key "status")
  "gc" '(magit-branch-or-checkout :which-key "branch or checkout")
  "gp" '(magit-push-current-to-pushremote :which-key "push to remote")) ;; Might be useful to add more keybindings as needed.

;; (use-package forge) ;; Use this package if I want to do extra git stuff from emacs.

(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

;; Emacs lisp.
(use-package elisp-format) ;; This goes in development.

(use-package prettier)

(add-hook 'after-init-hook #'global-prettier-mode)

(use-package vterm
  :commands vterm
  :config
  (setq vterm-max-scrollback 10000))

;; Leader keys for vterm

(mariano/leader-keys
  "t" '(:ignore t :which-key "terminal")
  "tt" '(vterm :which-key "terminal same window")
  "to" '(vterm-other-window :which-key "terminal other window"))

(use-package origami)

(defun mariano/dired-setup ()
  (auto-revert-mode)
  (dired-hide-details-mode))

(use-package dired-single) ;; Use only a single dired buffer.

(use-package dired
  :ensure nil ;; This is a built-in package so no need to ensure it.
  :hook (dired-mode . mariano/dired-setup)
  :commands (dired dired-jump) ;; Commands that activate the package.
  :custom ((dired-listing-switches "-algh --group-directories-first"))
  :config
  (setq delete-by-moving-to-trash t) ;; Use system trash instead or permanent delete.
  (evil-collection-define-key 'normal 'dired-mode-map ;; Use h and l for quick navigation.
    "h" 'dired-single-up-directory
    "l" 'dired-single-buffer))

(use-package diredfl
  :custom((diredfl-global-mode t)))

(use-package all-the-icons-dired
  :hook (dired-mode . all-the-icons-dired-mode))

;; Dired leader keys.
(mariano/leader-keys
  "j" '(dired-jump :which-key "Open in dired"))

(defun mariano/open-zshell-config ()
  (interactive)
  (find-file "~/.zshrc"))

(mariano/leader-keys
  "c" '(:ignore t :which-key "config files")
  "cz" '(mariano/open-zshell-config :which-key "zshell config"))

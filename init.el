;; Load the custom file.
(setq custom-file "~/.emacs.d/custom.el")
(load custom-file)

(add-to-list 'load-path "~/.emacs.d/local-packages")

(setq inhibit-startup-message t)

; Always start as a full frame.
(add-to-list 'default-frame-alist '(fullscreen . maximized))

; Set right command key to meta.
(setq ns-right-command-modifier 'meta)

(scroll-bar-mode -1) ; Disable visible scrollbar.
(tool-bar-mode -1) ; Disable the toolbar.
(tooltip-mode -1) ; Disable tooltips.
(set-fringe-mode 10) ; Breathing room for windows.

; Set up the visible bell.
(setq visible-bell nil
      ring-bell-function 'flash-mode-line)
(defun flash-mode-line ()
  (invert-face 'mode-line)
  (run-with-timer 0.1 nil #'invert-face 'mode-line))

;; ---- Setting up font
(set-face-attribute 'default nil :font "Fira Code Retina") ; TODO: setup ligatures.

;; Make ESC quit prompts.
(global-set-key (kbd "<escape>") 'keyboard-escape-quit)


;; Initialize package sources.
(require 'package)

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
(setq use-package-always-ensure t)


(use-package swiper)

;; Use counsel for M-x when switching buffers and when opening files.
(use-package counsel
  :bind (("M-x" . counsel-M-x)
	 ("C-x b" . counsel-ibuffer)
	 ("C-x C-f" . counsel-find-file)
	 :map minibuffer-local-map ; TODO: not exactly sure what this is for, investigate.
	 ("C-r" . 'counsel-minibuffer-history)))

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


(use-package doom-modeline
  :init (doom-modeline-mode 1))

;; Enable ligatures for fonts that allow it (Fira Code does).
(use-package ligature
  :ensure nil
  :config
  ;; Enable the "www" ligature in every possible major mode
  (ligature-set-ligatures 't '("www"))
  ;; Enable traditional ligature support in eww-mode, if the
  ;; `variable-pitch' face supports it
  (ligature-set-ligatures 'eww-mode '("ff" "fi" "ffi"))
  ;; Enable all Cascadia Code ligatures in programming modes
  (ligature-set-ligatures 'prog-mode '("www" "**" "***" "**/" "*>" "*/" "\\\\" "\\\\\\" "{-" "::"
				       ":::" ":=" "!!" "!=" "!==" "-}" "----" "-->" "->" "->>"
				       "-<" "-<<" "-~" "#{" "#[" "##" "###" "####" "#(" "#?" "#_"
				       "#_(" ".-" ".=" ".." "..<" "..." "?=" "??" ";;" "/*" "/**"
				       "/=" "/==" "/>" "//" "///" "&&" "||" "||=" "|=" "|>" "^=" "$>"
				       "++" "+++" "+>" "=:=" "==" "===" "==>" "=>" "=>>" "<="
				       "=<<" "=/=" ">-" ">=" ">=>" ">>" ">>-" ">>=" ">>>" "<*"
				       "<*>" "<|" "<|>" "<$" "<$>" "<!--" "<-" "<--" "<->" "<+"
				       "<+>" "<=" "<==" "<=>" "<=<" "<>" "<<" "<<-" "<<=" "<<<"
				       "<~" "<~~" "</" "</>" "~@" "~-" "~>" "~~" "~~>" "%%"))
  ;; Enables ligature checks globally in all buffers.  You can also do it
  ;; per mode with `ligature-mode'.
  (global-ligature-mode t))

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

(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

;; Show completion after pressing a prefix.x
(use-package which-key
  :diminish
  :init (which-key-mode)
  :config
  (setq which-key-idle-delay 0.3))

;; Show description and keybindings for commands when using counsel-M-x
(use-package ivy-rich
  :init
  (ivy-rich-mode))

;; Show more information in help pages.
;; TODO: helpful is not working right now, try again later.
(use-package helpful
 :init
 (setq counsel-describe-function-function #'helpful-callable)
 (setq counsel-describe-variable-function #'helpful-variable)
 :bind
 ([remap describe-function] . counsel-describe-function)
 ([remap describe-command] . helpful-command)
 ([remap describe-variable] . counsel-describe-variable)
 ([remap describe-key] . helpful-key))

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
  

;; Setup leader key.
(use-package general
  :config
  (general-create-definer mariano/leader-keys
    :keymaps '(normal visual emacs) ; Where the prefix will work. Consider taking out insert mode if too annoying.
    :prefix "SPC"
    :gloabl-prefix "C-SPC")) ;; This prefix will work everywhere.

;; Basic leader keys.
(mariano/leader-keys
  "s" 'save-buffer)

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
  "wd" '(delete-window :which-key "delete current window"))

;; Kill all buffers except the current one.
(defun kill-other-buffers ()
    "Kill all other buffers."
    (interactive)
    (mapc 'kill-buffer ;; Apply the command kill-buffer to all elements of the list.
          (delq (current-buffer) ;; Remove the current buffer from the list of to-be-removed. 
                (cl-remove-if-not 'buffer-file-name (buffer-list))))) ;; Only remove file buffers.

;; Buffer leader keys.
(mariano/leader-keys
  "b" '(:ignore t :which-key "buffers")
  "bs" '(counsel-switch-buffer :which-key "switch buffer")
  "bk" '(kill-buffer :which-key "kill buffer")
  "be" '(eval-buffer :which-key "eval buffer")
  "bO" '(kill-other-buffers :which-key "keep only the current buffer"))

;; Files leader keys.
(mariano/leader-keys
  "f" '(:ignore t :which-key "files")
  "ff" '(counsel-find-file :which-key "find file")
  "fw" '(save-buffer :which-key "write file"))

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
  (key-chord-define evil-insert-state-map "kj" 'evil-normal-state))

(use-package projectile
  :diminish
  :config (projectile-mode)
  :bind-keymap
  ("C-c p" . projectile-command-map)
  :init
  (when (file-directory-p "~/dev") ;; Setup ~/dev as my local code repository.
    (setq projectile-project-search-path '("~/dev")))
  (setq projectile-switch-project-action #'projectile-dired)) ;; This does not work with counsel-projectile installed, refer to https://github.com/ericdanan/counsel-projectile/issues/62

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
  "gp" '(magit-push-current-to-pushremote :which-key "push to remote"))

;; (use-package forge) ;; Use this package if I want to do extra git stuff from emacs.

;; Display line numbers (Only in prog modes).
(column-number-mode) ; Show colum in modeline.
(global-display-line-numbers-mode t)
;; Always use relative when using line numbers mode.
(add-hook 'display-line-numbers-mode-hook (lambda () (setq display-line-numbers 'relative)))

;; Disable line numbers for certain modes.
(dolist (mode '(org-mode-hook
		term-mode-hook
		shell-mode-hook
		eshell-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

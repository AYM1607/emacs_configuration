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

;; ---------- Setting up font
(set-face-attribute 'default nil :font "Fira Code Retina") ; TODO: setup ligatures.

; Setup theme
(load-theme 'wombat)

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
(use-package counsel)

(use-package ivy
  :diminish
  :bind (("C-s" . swiper)                 ; Change the default global command to swiper.
	 :map ivy-minibuffer-map          ; Bindings for mminibuffer (prompts)
	 ("TAB" . ivy-alt-done)
	 ("C-j" . ivy-next-line)          
	 ("C-k" . ivy-previous-line)      
	 :map ivy-switch-buffer-map       ; Bindings for switching buffers (C-x C-b)
	 ("C-k" . ivy-previous-lie)
	 ("C-k" . ivy-done)               ; Test out, change if not comfortable.
	 ("C-k" . ivy-switch-buffer-kill) ; Test, out change if not comfortable.
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

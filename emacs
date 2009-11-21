;; feel out the system
(defvar macosx-p (string-match "darwin" (symbol-name system-type)))
(defvar linux-p (string-match "gnu/linux" (symbol-name system-type)))

;; disable splash screen and startup message
(setq inhibit-startup-message t)
;(setq initial-scratch-message nil)

;; don't litter my filesystem with ~ files!
(setq make-backup-files nil)

;;;;;;;;;;;;;;;;;;;;;;
;; setup load paths ;;
;;;;;;;;;;;;;;;;;;;;;;

(defun add-to-load-path (file)
  "Add FILE to `load-path' if it is readable."
  (if (file-readable-p file)
      (add-to-list 'load-path file)))

;; use icicles for enhanced minibuffer completion and lots of other goodies
(let ((load-paths '("~/.emacs.d" "~/.emacs.d/icicles")))
  (mapcar 'add-to-load-path load-paths))


;;;;;;;
;; c ;;
;;;;;;;

;; Make a non-standard key binding.  We can put this in
;; c-mode-base-map because c-mode-map, c++-mode-map, and so on,
;; inherit from it.
(defun sjs-c-initialization-hook ()
  (define-key c-mode-base-map "\r" 'newline-and-indent)) ; auto indent after inserting newline
(add-hook 'c-initialization-hook 'sjs-c-initialization-hook)

;; offset customizations not in my-c-style
;; This will take precedence over any setting of the syntactic symbol
;; made by a style.
;; (setq c-offsets-alist '((member-init-intro . ++)))

;; Create my personal style.
(defconst my-c-style
  '("linux"
    (c-tab-always-indent        . t)
    (c-basic-offset             . 8)
;;     (c-comment-only-line-offset . 4)
;;     (c-hanging-braces-alist     . ((substatement-open after)
;;                                    (brace-list-open)))
;;     (c-hanging-colons-alist     . ((member-init-intro before)
;;                                    (inher-intro)
;;                                    (case-label after)
;;                                    (label after)
;;                                    (access-label after)))
    (c-cleanup-list             . (list-close-comma
                                   compact-empty-funcall
                                   one-liner-defun
                                   defun-close-semi))
;;     (c-offsets-alist            . ((arglist-close . c-lineup-arglist)
;;                                    (substatement-open . 0)
;;                                    (case-label        . 4)
;;                                    (block-open        . 0)
;;                                    (knr-argdecl-intro . -)))
;;     (c-echo-syntactic-information-p . t)
    )
  "how sjs likes his C")
(c-add-style "sjs" my-c-style)

;; Customizations for all modes in CC Mode.
(defun sjs-c-mode-common-hook ()
  ;; set my personal style for the current buffer
  (c-set-style "sjs")
  ;; other customizations
  (setq tab-width 8
        ;; this will make sure spaces are used instead of tabs
        indent-tabs-mode nil)
  (c-toggle-auto-newline 1))
;;   (setq skeleton-pair t)
;;   (setq skeleton-autowrap t)
;;   (let ((chars '("'" "\"" "(" "[" "{")))
;;     (mapcar (lambda (char)
;; 	      (local-set-key char 'skeleton-pair-insert-maybe)) chars))
(add-hook 'c-mode-common-hook 'sjs-c-mode-common-hook)


;;;;;;;;;;;
;; shell ;;
;;;;;;;;;;;

;; chmod u+x files that have a shebang line
(add-hook 'after-save-hook 'executable-make-buffer-file-executable-if-script-p)

(add-to-list 'auto-mode-alist '("zsh\(rc\|env\)$" . sh-mode))


;;;;;;;;;;
;; ruby ;;
;;;;;;;;;;

;; Based on http://infolab.stanford.edu/~manku/dotemacs.html
(autoload 'ruby-mode "ruby-mode"
    "Mode for editing ruby source files")
(autoload 'ruby-electric-mode "ruby-electric"
    "Mode for automatically inserting end and such for Ruby")
(add-to-list 'auto-mode-alist '("\\.rb$" . ruby-mode))
(add-to-list 'interpreter-mode-alist '("ruby" . ruby-mode))
(autoload 'run-ruby "inf-ruby"
    "Run an inferior Ruby process")
(autoload 'inf-ruby-keys "inf-ruby"
    "Set local key defs for inf-ruby in ruby-mode")
(add-hook 'ruby-mode-hook
     '(lambda ()
         (inf-ruby-keys)
	 (ruby-electric-mode)))
(autoload 'rubydb "rubydb3x" "Ruby debugger" t)


;;;;;;;;;;;;;
;; haskell ;;
;;;;;;;;;;;;;

;; (if (file-readable-p "~/.emacs.d/haskell/haskell-site-file.el")
;;   (load "~/.emacs.d/haskell/haskell-site-file.el" nil t))


;;;;;;;;;;;
;; rails ;;
;;;;;;;;;;;

;(require 'rails)


;; wraps selected text with the given tag or inserts the tag if nothing selected
(require 'tagify)


;;;;;;;;;;;;;;;;;;
;; mojo (webOS) ;;
;;;;;;;;;;;;;;;;;;

(require 'mojo)


;;;;;;;;;;;;;;;;
;; javascript ;;
;;;;;;;;;;;;;;;;

(autoload 'js2-mode "js2-mode" nil t)
(add-to-list 'auto-mode-alist '("\\.js$" . js2-mode))


;;;;;;;;;;;;
;; markup ;;
;;;;;;;;;;;;

;; (require 'textile-mode)
;; (add-to-list 'auto-mode-alist '("\\.textile\\'" . textile-mode))

;; (require 'yaml-mode)
;; (add-to-list 'auto-mode-alist '("\\.yml$" . yaml-mode))


;; keep a list of recently visited files
(require 'recentf)
(recentf-mode 1)

;; remember my position in files
(require 'saveplace)
(setq-default save-place t)


;;;;;;;;;;;;;;;;;;;;;
;; lisp and scheme ;;
;;;;;;;;;;;;;;;;;;;;;

;; use ElSchemo as the default scheme
(setq scheme-program-name "~/Projects/elschemo/elschemo")

;; setup slime
;(require 'slime)
;(add-hook 'lisp-mode-hook (lambda () (slime-mode t)))
;(add-hook 'scheme-mode-hook (lambda () (slime-mode t)))
;(add-hook 'inferior-lisp-mode-hook (lambda () (inferior-slime-mode t)))
;(add-hook 'inferior-scheme-mode-hook (lambda () (inferior-slime-mode t)))

;; use sbcl for lisp
(setq inferior-lisp-program "/usr/bin/sbcl")


;;;;;;;;;;;;;;;;;;;;
;; customizations ;;
;;;;;;;;;;;;;;;;;;;;

;; setup tramp mode
(setq tramp-default-method "ssh")

;; complete like zsh's complete-in-word option (p-b expands to print-buffer)
(load "complete")

;; show the date & time in the mode line
(setq display-time-day-and-date t)
(display-time)

(setq track-eol t)               ; When at EOL, C-n and C-p move to EOL on other lines
(setq indent-tabs-mode nil)      ; never insert tabs

;; ah, now I can read the text I'm supposed to correct
;; (progn
;;   (set-face-background 'flymake-errline "red4")
;;   (set-face-background 'flymake-warnline "dark slate blue"))


;;;;;;;;;;;;;;;;;;
;; key bindings ;;
;;;;;;;;;;;;;;;;;;
;; TODO add these only to appropriate modes

;; custom key bindings under a common prefix
(global-set-key "\C-z" nil)             ; Suspend is useless. Give me C-z!
(global-set-key "\C-zf" 'find-file-at-point)
(global-set-key "\C-zz" 'shell)         ; z for zsh
(global-set-key "\C-zl" 'duplicate-line)
(global-set-key "\C-zg" 'goto-line)
(global-set-key "\C-zr" 'query-replace-regexp)
(global-set-key "\C-z\C-r" 'reload-dot-emacs)
(global-set-key "\C-zc" 'comment-line)
(global-set-key "\C-zs" 'run-scheme)
(global-set-key "\C-z\C-t" 'totd)
(global-set-key [f5] 'compile)

;; *** only do this for specific modes?
;; help out a TextMate junkie
;; (setq skeleton-pair t)
;; (setq skeleton-autowrap t)

;; (let ((chars '("'" "\"" "`" "(" "[" "{")))
;;   (mapcar (lambda (char)
;;             (global-set-key char 'skeleton-pair-insert-maybe)) chars))

;; web searches
(global-set-key "\C-zwg" 'web-search-google)
(global-set-key "\C-zww" 'web-search-wikipedia)
(global-set-key "\C-zwih" 'web-search-iso-hunt)
(global-set-key "\C-zwpb" 'web-search-pirate-bay)

;; extend Emacs' default key binding space
(global-set-key "\C-x\C-b" 'bs-show)    ; use the buffer list buffer menu
(global-set-key "\C-x\C-r" 'recentf-find-files-compl)

;; use the X clipboard for cut/copy/paste
(global-set-key "\C-w" 'clipboard-kill-region)
(global-set-key "\M-w" 'clipboard-kill-ring-save)
(global-set-key "\C-y" 'clipboard-yank)

;; wrap a region with an HTML/XML tag
(global-set-key "<"  'tagify-region-or-insert-self)
(global-set-key "\C-zt" 'tagify-region-or-insert-tag)

;; mojo keyboard shortcuts
(global-set-key [f2] 'mojo-generate-scene)
(global-set-key [f3] 'mojo-emulate)
(global-set-key [f4] 'mojo-package)
(global-set-key [f5] 'mojo-package-install-and-inspect)

;; XXX:todo need a version of this that inserts a line terminator as well
;; Use C-j!
;;(global-set-key [M-return] 'move-end-of-line-insert-newline)

;; saved macros

(defun duplicate-line (&optional arg)
    "Duplicate the current line."
    (interactive "p")
    (save-excursion
      (move-beginning-of-line nil)
      (let ((beg (point)))
	(move-end-of-line nil)
	(let* ((end (point))
	       (txt (buffer-substring beg end)))
	  (newline)
	  (insert txt)))))

(fset 'comment-line
   (lambda (&optional arg)
     "Comment or uncomment the current line using `comment-dwim'."
     (interactive "p")
     (kmacro-call-macro (quote ([1 67108896 14 134217787 16] 0 "%d")) arg)))

;; function definitions

;; Reload the .emacs file with a minimum of effort,
;; first saving histories with Persistent
(defun reload-dot-emacs () (interactive)
  "If there is a buffer named .emacs save it. Reload ~/.emacs if it exists."
  (if (get-buffer ".emacs")
    (save-excursion
      (set-buffer ".emacs")
      (save-buffer)))
  (if (file-exists-p "~/.emacs")
    (load-file "~/.emacs")))

;; find recently visited files quickly
(defun recentf-find-files-compl ()
  "Find a file that has recently been visited."
  (interactive)
  (let* ((all-files recentf-list)
     (tocpl (mapcar (function
     (lambda (x) (cons (file-name-nondirectory x) x))) all-files))
     (prompt (append '("Recent file name: ") tocpl))
     (fname (completing-read (car prompt) (cdr prompt) nil nil)))
     (find-file (or (cdr (assoc fname tocpl))
                    fname))))


;; quickly search the web
(defun web-search (name url-template)
  "Prompt for a query in the minibuffer, launch the web browser and query the url given."
  (let ((search (read-from-minibuffer (concat "Search " name ": "))))
    (browse-url (concat url-template search))))

(defun web-search-google ()
  (interactive)
  (web-search "Google" "http://www.google.com/search?q="))

(defun web-search-wikipedia ()
  (interactive)
  (web-search "Wikipedia" "http://en.wikipedia.org/wiki/Special:Search?search="))

(defun web-search-iso-hunt ()
  (interactive)
  (web-search "ISO Hunt" "http://www.isohunt.com/torrents/?ihq="))

(defun web-search-pirate-bay ()
  (interactive)
  (web-search "The Pirate Bay" "http://thepiratebay.org/search/"))

(cond ((file-readable-p "~/.emacs.d/color-theme")
      (add-to-list 'load-path "~/.emacs.d/color-theme")
      (require 'color-theme)

;; dark themes
;; (color-theme-arjen)             ;; easy on the eyes, but sucks for Ruby
;; (color-theme-billw)          ;; bright yellow and white, decent for Ruby
;; (color-theme-charcoal-black) ;; pastels, low contrast, decent for Ruby
;; (color-theme-dark-laptop)    ;; red comments, so-so, decent for Ruby
;; (color-theme-euphoria)               ;; pink and green, not too shabby
;; (color-theme-ld-dark)                ;; easy on the eyes, low contrast, not bad
(color-theme-midnight)               ;; pretty nice, but very basic, good for Ruby
;; (color-theme-pok-wob)                ;; white and yellow, kind of lame
;; (color-theme-simple-1)               ;; red comments, white text
;; (color-theme-taming-mr-arneson) ;; blue text, red comments, status bar blends into document
;; (color-theme-taylor)            ;; beige text, orange comments
;; (color-theme-tty-dark)
))

;; always highlight syntax
(global-font-lock-mode t)
(setq font-lock-maximum-decoration t)   ; highlight liberally

(autoload 'ansi-color-for-comint-mode-on "ansi-color" nil t)
(add-hook 'shell-mode-hook 'ansi-color-for-comint-mode-on)

(defun totd ()
  (interactive)
  (with-output-to-temp-buffer "*Tip of the day*"
    (let* ((commands (loop for s being the symbols
                           when (commandp s) collect s))
           (command (nth (random (length commands)) commands)))
      (princ
       (concat "Your tip for the day is:\n"
               "========================\n\n"
               (describe-function command)
               "\n\nInvoke with:\n\n"
               (with-temp-buffer
                 (where-is command t)
                 (buffer-string)))))))


(custom-set-variables
  ;; custom-set-variables was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(blink-cursor-mode nil)
 '(case-fold-search t)
 '(column-number-mode t)
 '(current-language-environment "UTF-8")
 '(default-input-method "rfc1345")
 '(face-font-family-alternatives (quote (("bistream vera sans mono" "courier" "fixed") ("helv" "helvetica" "arial" "fixed"))))
 '(global-font-lock-mode t nil (font-lock))
 '(icicle-reminder-prompt-flag 5)
 '(mojo-build-directory "~/Projects/brighthouse/webOS/build")
 '(mojo-project-directory "~/Projects/brighthouse/webOS")
 '(remote-shell-program "/usr/bin/ssh")
 '(save-place t nil (saveplace))
 '(scroll-bar-mode nil)
 '(show-paren-mode t nil (paren))
 '(tool-bar-mode nil)
 '(transient-mark-mode t))

(if linux-p
    (custom-set-faces
     ;; custom-set-faces was added by Custom.
     ;; If you edit it by hand, you could mess it up, so be careful.
     ;; Your init file should contain only one such instance.
     ;; If there is more than one, they won't work right.

     '(default ((t (:stipple nil :background "black" :foreground "grey85" :inverse-video nil :box nil :strike-through nil :overline nil :underline nil :slant normal :weight normal :height 90 :width normal :family "bitstream-bitstream vera sans mono"))))))

(put 'upcase-region 'disabled nil)
(put 'downcase-region 'disabled nil)
(custom-set-faces
  ;; custom-set-faces was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 )

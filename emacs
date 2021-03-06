;;;
;;; sjs' emacs config
;;;


;; feel out the system
(defvar macosx-p (string-match "darwin" (symbol-name system-type)))
(defvar linux-p (string-match "gnu/linux" (symbol-name system-type)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; setup load paths 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun add-to-load-path (file)
  "Add FILE to `load-path' if it is readable."
  (if (file-readable-p file)
      (add-to-list 'load-path file)))

(add-to-load-path "~/config/emacs.d")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; global config
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(setq inhibit-startup-message t)
(setq make-backup-files nil)
(global-subword-mode 1)

(setq auto-revert-interval 2)
(global-auto-revert-mode t)


;; map cmd to meta (Emacs.app 23.2)
(when macosx-p
  (setq mac-option-key-is-meta nil)
  (setq mac-command-key-is-meta t)
  (setq mac-command-modifier 'meta)
  (setq mac-option-modifier 'super))

;; keep a list of recently visited files
(require 'recentf)
(recentf-mode 1)

;; remember my position in files
(require 'saveplace)
(setq-default save-place t)

;; always highlight syntax
(global-font-lock-mode t)
(setq font-lock-maximum-decoration t)   ; highlight liberally

(autoload 'ansi-color-for-comint-mode-on "ansi-color" nil t)
(add-hook 'shell-mode-hook 'ansi-color-for-comint-mode-on)

;; always start emacs server
(server-start)

;; setup tramp mode
;; (setq tramp-default-method "ssh")

;; complete like zsh's complete-in-word option (p-b expands to print-buffer)
(load "complete")

;; show the date & time in the mode line
(setq display-time-day-and-date t)
(display-time)

(setq track-eol t)               ; When at EOL, C-n and C-p move to EOL on other lines
(setq indent-tabs-mode nil)      ; never insert tabs

;; nav - awesome filesystem navigation, sort of like TextMate's project drawer
(add-to-load-path "~/config/emacs.d/emacs-nav")
(require 'nav)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; peepopen and textmate mode
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(add-to-list 'load-path "~/.emacs.d/vendor/")
(require 'textmate)
(require 'peepopen)
(textmate-mode)

;; open files in current frame
(setq ns-pop-up-frames nil)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; minimap
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(require 'minimap)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; undo-tree
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(require 'undo-tree)
(global-undo-tree-mode)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; c
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(setq c-mode-hook
    (function (lambda ()
                (setq indent-tabs-mode nil)
                (setq c-indent-level 4))))

(setq objc-mode-hook
    (function (lambda ()
                (setq indent-tabs-mode nil)
                (setq c-indent-level 4))))

;; Make a non-standard key binding.  We can put this in
;; c-mode-base-map because c-mode-map, c++-mode-map, and so on,
;; inherit from it.
(defun sjs-c-initialization-hook ()
  (define-key c-mode-base-map "\r" 'newline-and-indent)) ; auto indent after inserting newline
(add-hook 'c-initialization-hook 'sjs-c-initialization-hook)

;; Create my personal style.
(defconst my-c-style
  '("linux"
    (c-tab-always-indent        . t)
    (c-basic-offset             . 4)
    (c-cleanup-list             . (brace-else-brace
    				   brace-elseif-brace
    				   brace-catch-brace
    				   defun-close-semi)))
  "how sjs likes his C")
(c-add-style "sjs" my-c-style)

;; Customizations for all modes in CC Mode.
(defun sjs-c-mode-common-hook ()
  ;; set my personal style for the current buffer
  (c-set-style "sjs")
  ;; other customizations
  (setq tab-width 4
        ;; this will make sure spaces are used instead of tabs
        indent-tabs-mode nil
	c-syntactic-indentation t
        c-tab-always-indent t)
  (c-toggle-auto-newline 1))
;;   (setq skeleton-pair t)
;;   (setq skeleton-autowrap t)
;;   (let ((chars '("'" "\"" "(" "[" "{")))
;;     (mapcar (lambda (char)
;; 	      (local-set-key char 'skeleton-pair-insert-maybe)) chars))
(add-hook 'c-mode-common-hook 'sjs-c-mode-common-hook)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; shell
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; chmod u+x files that have a shebang line
(add-hook 'after-save-hook 'executable-make-buffer-file-executable-if-script-p)

(add-to-list 'auto-mode-alist '("zshenv$" . sh-mode))
(add-to-list 'auto-mode-alist '("zshrc$" . sh-mode))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ruby
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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

(add-to-list 'auto-mode-alist '(".irbrc$" . ruby-mode))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; haskell
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(if (file-readable-p "~/.emacs.d/haskell/haskell-site-file.el")
  (load "~/.emacs.d/haskell/haskell-site-file.el" nil t))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; rails
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;(require 'rails)


;; wraps selected text with the given tag or inserts the tag if nothing selected
(require 'tagify)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; javascript
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; js-mode (espresso)
;; Espresso mode has sane indenting so we use that.
(setq js-indent-level 2)

;; Customize JS2
(setq js2-basic-offset 2)
(setq js2-cleanup-whitespace t)

(autoload 'js2-mode "js2-mode" nil t)
(add-to-list 'auto-mode-alist '("\\.js$" . js2-mode))
(add-to-list 'auto-mode-alist '("Jakefile$" . js2-mode))
(add-hook 'js2-mode-hook (lambda () (slime-js-minor-mode 1)))
(global-set-key [f5] 'slime-js-reload)

;; Custom indentation function since JS2 indenting is terrible.
;; Uses js-mode's (espresso-mode) indentation semantics.
;;
;; Based on: http://mihai.bazon.net/projects/editing-javascript-with-emacs-js2-mode
;; (Thanks!)
(defun my-js2-indent-function ()
  (interactive)
  (save-restriction
    (widen)
    (let* ((inhibit-point-motion-hooks t)
           (parse-status (save-excursion (syntax-ppss (point-at-bol))))
           (offset (- (current-column) (current-indentation)))
           (indentation (js--proper-indentation parse-status))
           node)

      (save-excursion

        ;; I like to indent case and labels to half of the tab width
        (back-to-indentation)
        (if (looking-at "case\\s-")
            (setq indentation (+ indentation (/ js-indent-level 2))))

        ;; consecutive declarations in a var statement are nice if
        ;; properly aligned, i.e:
        ;;
        ;; var foo = "bar",
        ;;     bar = "foo";
        (setq node (js2-node-at-point))
        (when (and node
                   (= js2-NAME (js2-node-type node))
                   (= js2-VAR (js2-node-type (js2-node-parent node))))
          (setq indentation (+ 4 indentation))))

      (indent-line-to indentation)
      (when (> offset 0) (forward-char offset)))))

(defun my-js2-mode-hook ()
  (if (not (boundp 'js--proper-indentation))
      (progn (js-mode)
             (remove-hook 'js2-mode-hook 'my-js2-mode-hook)
             (js2-mode)
             (add-hook 'js2-mode-hook 'my-js2-mode-hook)))
  (set (make-local-variable 'indent-line-function) 'my-js2-indent-function)
  (define-key js2-mode-map [(return)] 'newline-and-indent)
  (define-key js2-mode-map [(backspace)] 'c-electric-backspace)
  (define-key js2-mode-map [(control d)] 'c-electric-delete-forward)
  (local-set-key "\C-m" 'newline)
  (setq indent-tabs-mode nil)
  (message "JS2 mode hook ran."))

;; Add the hook so this is all loaded when JS2-mode is loaded
(add-hook 'js2-mode-hook 'my-js2-mode-hook)

(autoload #'espresso-mode "espresso" "Start espresso-mode" t)
(add-to-list 'auto-mode-alist '("\\.json$" . espresso-mode))


;; coffee script
(require 'coffee-mode)

;; mustache
(require 'mustache-mode)


;; css
(setq css-mode-hook (lambda () (setq indent-tabs-mode nil)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; mojo (webos)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;(require 'mojo)

;; enable Mojo for CSS, HTML, JS, and JSON files within a Mojo project
;; root.  Did I forget anything?
;(mojo-setup-mode-hooks 'css-mode-hook 'js2-mode-hook 'espresso-mode-hook 'html-mode-hook)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; inferior javascript
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(require 'js-comint)
;(setq inferior-js-program-command "/usr/local/bin/v8")
(setq inferior-js-program-command "/opt/local/bin/js -v 1.8")
(add-hook 'js2-mode-hook '(lambda ()
			    (local-set-key "\C-x\C-e" 'js-send-last-sexp)
			    (local-set-key "\C-\M-x" 'js-send-last-sexp-and-go)
			    (local-set-key "\C-cb" 'js-send-buffer)
			    (local-set-key "\C-c\C-b" 'js-send-buffer-and-go)
			    (local-set-key "\C-cl" 'js-load-file-and-go)
			    ))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; python
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; handy but ugly as fuck
(autoload 'whitespace-mode "whitespace"
  "Toggle whitespace visualization." t)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; erlang
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(when (file-exists-p "/opt/local/lib/erlang")
  (setq load-path (cons "/opt/local/lib/erlang/lib/tools-2.6.5/emacs" load-path))
  (setq erlang-root-dir "/opt/local/lib/erlang/otp")
  (setq exec-path (cons "/opt/local/lib/erlang/bin" exec-path))
  (require 'erlang-start))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; markup
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; (require 'textile-mode)
;; (add-to-list 'auto-mode-alist '("\\.textile\\'" . textile-mode))

(require 'yaml-mode)
(add-to-list 'auto-mode-alist '("\\.yml$" . yaml-mode))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; lisp and scheme
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; recognize my non-standard emacs config location
(add-to-list 'auto-mode-alist '("config/emacs$" . emacs-lisp-mode))

;; use ElSchemo as the default scheme
(setq scheme-program-name "~/Projects/elschemo/elschemo")

;; use sbcl for lisp
(setq inferior-lisp-program "/usr/bin/env sbcl")

;; setup slime
(when (file-exists-p "~/.slime")
  (add-to-list 'load-path "~/.slime")
  (require 'slime)
  (slime-setup '(slime-repl slime-js))
  (add-hook 'lisp-mode-hook (lambda () (slime-mode t)))
  (add-hook 'scheme-mode-hook (lambda () (slime-mode t)))
  (add-hook 'inferior-lisp-mode-hook (lambda () (inferior-slime-mode t)))
  (add-hook 'inferior-scheme-mode-hook (lambda () (inferior-slime-mode t))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; key bindings
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Unhijack Cmd-H
(global-set-key [(super h)] 'mark-paragraph)
(global-set-key "\M-h" 'ns-do-hide-emacs)

;; always use regexp searching
(global-set-key "\C-s" 'isearch-forward-regexp)
(global-set-key "\C-r" 'isearch-backward-regexp)

;; custom key bindings under a common prefix
;; (Suspend is useless. Give me C-z!)
(global-unset-key "\C-z")
(global-set-key "\C-z" nil)
(global-set-key "\C-zc" 'compile)
(global-set-key "\C-zf" 'find-file-at-point)
(global-set-key "\C-zg" 'goto-line)
(global-set-key "\C-zj" 'run-js)
(global-set-key "\C-zl" 'duplicate-line)
(global-set-key "\C-zm" 'minimap-create)
(global-set-key "\C-zM" 'minimap-kill)
(global-set-key "\C-zr" 'query-replace-regexp)
(global-set-key "\C-zs" 'run-scheme)
(global-set-key "\C-zt" 'tagify-region-or-insert-tag)
(global-set-key "\C-zz" 'shell)         ; z for zsh
(global-set-key "\C-z\C-r" 'reload-dot-emacs)
(global-set-key "\C-z\C-t" 'totd)

;; extend Emacs' default key binding space
(global-set-key [(super b)] 'bs-show)    ; use the buffer list buffer menu
(global-set-key "\C-x\C-r" 'recentf-find-files-compl) ; unused, remove?

;; use the X clipboard for cut/copy/paste
(global-set-key "\C-w" 'clipboard-kill-region)
(global-set-key "\M-w" 'clipboard-kill-ring-save)
(global-set-key "\C-y" 'clipboard-yank)

;; wrap a region with an HTML/XML tag
(global-set-key "<"  'tagify-region-or-insert-self)

;; Select the enclosed parens/brackets/braces
(global-set-key "\M-B" 'select-enclosing-pair)

(when macosx-p
  ;; nice OS X keyboard behaviors that save my pinky too
  (defun save-the-pinky-buffer () (interactive) (message "Save your pinky! Use s-b (Opt-b) instead."))
  (defun save-the-pinky-open   () (interactive) (message "Save your pinky! Use M-o (Cmd-o) instead."))
  (defun save-the-pinky-save   () (interactive) (message "Save your pinky! Use M-s (Cmd-s) instead."))
  (defun save-the-pinky-undo   () (interactive) (message "Save your pinky! Use M-z (Cmd-z) instead."))
  (defun save-the-pinky-window () (interactive) (message "Save your pinky! Use M-` (Cmd-`) instead."))
  (global-set-key "\C-_" 'save-the-pinky-undo)
  (global-set-key "\C-x\C-f" 'save-the-pinky-open)
  (global-set-key "\C-xo" 'save-the-pinky-window)
  (global-set-key "\C-x\C-s" 'save-the-pinky-save)
  (global-set-key "\C-x\C-b" 'save-the-pinky-buffer)
  
  (global-set-key "\M-n" 'new-frame)
  (global-set-key "\M-o" 'find-file)
  (global-set-key "\M-s" 'save-buffer)
  (global-set-key "\M-z" 'undo)
  (global-set-key [(meta down)] 'end-of-buffer)
  (global-set-key [(meta up)] 'beginning-of-buffer)
  (global-set-key [(meta right)] 'end-of-line)
  (global-set-key [(meta left)] 'beginning-of-line)

  ;; can't seem to un-hijack cmd-`, so make it do something useful
  (global-set-key "\M-`" 'other-window-in-any-frame)

  ;; find files like textmate
  (global-set-key "\M-F" 'textmate-find-regex-in-project)
)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; utilities & customizations
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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

;; switch to the next window, in any visible frame
(defun other-window-in-any-frame (&optional arg)
  "Switch to the next window using `next-window', with ALL-FRAMES
set to 'visible.  If the next window is on a different frame
switch to that frame first using `select-frame-set-input-focus'.

If N is non-nil switch to the nth next window."
  (interactive "p")
  (setq arg (or arg 1))
  (let ((gt-or-lt (if (> arg 0) #'> #'<))
	(sign (if (> arg 0) 1 -1)))
    (while (apply gt-or-lt arg '(0))
      (let ((window (if (= sign 1)
			(next-window (selected-window) nil 'visible)
		      (previous-window (selected-window) nil 'visible))))
	(when (not (member window (window-list)))
	  (dolist (frame (delq (selected-frame) (frame-list)))
	    (when (member window (window-list frame))
	      (select-frame-set-input-focus frame))))
	(select-window window))
      (setq arg (- arg sign)))))

;; Reload the .emacs file with a minimum of effort,
;; first saving histories with Persistent
(defun reload-dot-emacs () (interactive)
  "If there is a buffer named .emacs save it. Reload ~/.emacs if it exists."
  (if (get-buffer "emacs")
    (save-excursion
      (set-buffer "emacs")
      (save-buffer)))
  (if (file-exists-p "~/config/emacs")
    (load-file "~/config/emacs")))

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


;; If it's not nailed down, steal it! This tries to mimic TextMate's
;; select enclosing braces function. Very handy.

;; It would be nice to take quotes into account but the current
;; algorithm doesn't play nice with pairs that are equal.
(defvar select-enclosing-pair-default-pairs
  "Pairs of characters to look for when marking an enclosed region."
  '((?( ?)) (?[ ?]) (?{ ?}) (?< ?>)))

;; Well, it's ugly as sin but it works in simple cases. Needs a
;; smarter algorithm to work in more situations. One example that
;; doesn't work with this algo: (something "<" 'other-stuff)
;;
;; FIXME there's at least one off-by-one error with the ignore-count
(defun select-enclosing-pair (&optional n pairs)
  "Select text between the innermost pair of characters given in
PAIRS, defaults are: (), [], {}, <>."
  (interactive "p")
  ;; FIXME use the n parameter. recursion? iteration?
  (let* ((pairs (or pairs select-enclosing-pair-default-pairs))
         (opening-chars (mapcar 'car pairs))
         (closing-chars (mapcar 'cadr pairs))
         (original-position (point))
         (opening-index original-position)
         (closing-index original-position)
         (i (1- original-position))
         (len (buffer-size))
         (opening-char (char-after i))
         (closing-char (char-after original-position))
         (opening-char-pos (position opening-char opening-chars))
         (closing-char-pos (position closing-char closing-chars))
         (ignore-count (if (position opening-char closing-chars) 1 0)))
    ;; (message "----")
    (while (and opening-char
                (or (not opening-char-pos)
                    (> ignore-count 0)))
      ;; (message "char at %d is %c" i opening-char)
      (when (and opening-char-pos (> ignore-count 0))
        (decf ignore-count))
      (decf i)
      (setq opening-char (char-after i))
      (setq opening-char-pos (position opening-char opening-chars))
      (when (position opening-char closing-chars)
        (incf ignore-count)))
    ;; (message "opening-char: %c i: %d" opening-char i)
    (when (and opening-char
               (position opening-char opening-chars))
      (setq opening-index i))
    ;;   (message "start: %d char: %c" i opening-char))
    ;; (message "char at %d is %s" i opening-char)

    ;; (message "----")
    ;; (message "closing-chars: %s" closing-chars)
    (when (and opening-char opening-char-pos)
      (setq i original-position)
      (setq ignore-count (if (position closing-char opening-chars) 1 0))
      (while (and closing-char
                  (or (not closing-char-pos)
                      (> ignore-count 0)
                      (not (= opening-char-pos closing-char-pos))))
        ;; (message "closing-char: %s (position closing-char closing-chars): %s" closing-char (position closing-char closing-chars))
        ;; (message "char at %d is %c" i closing-char)
        (when (and closing-char-pos (> ignore-count 0))
          (decf ignore-count))
        (incf i)
        (setq closing-char (char-after i))
        (setq closing-char-pos (position closing-char closing-chars))
        (when (position closing-char opening-chars)
          (incf ignore-count)))
      ;; (message "closing-char: %s i: %d " closing-char i)
      (when (and closing-char
                 closing-char-pos
                 (= opening-char-pos closing-char-pos))
        (setq closing-index i))
      ;;   (message "end: %d char: %c" i closing-char))
      ;; (message "char at %d is %s" i closing-char)
      ;; (message "----")
      (when (and opening-char closing-char
                 opening-char-pos closing-char-pos
                 (not (= opening-index closing-index))
                 (= opening-char-pos closing-char-pos))
        ;; (message "doing it")
        (push-mark opening-index 'nomsg t)
        (goto-char (1+ closing-index))))))

(cond ((file-readable-p "~/.emacs.d/color-theme")
       (add-to-list 'load-path "~/.emacs.d/color-theme")
       (require 'color-theme)

;; dark themes
;; (color-theme-charcoal-black) ;; pastels, low contrast ***
;; (color-theme-midnight)       ;; grey comments, so-so ***
;; (color-theme-taylor)            ;; beige text, orange comments ****
(when (file-readable-p "~/.emacs.d/color-theme-tangotango.el")
  (require 'color-theme-tangotango)
  (color-theme-tangotango))            ;; beige text, orange comments ****
))

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
 '(c-hanging-semi&comma-criteria (quote set-from-style))
 '(case-fold-search t)
 '(column-number-mode t)
 '(current-language-environment "UTF-8")
 '(default-input-method "rfc1345")
 '(display-time-mode t)
 '(face-font-family-alternatives (quote (("bistream vera sans mono" "courier" "fixed") ("helv" "helvetica" "arial" "fixed"))))
 '(global-font-lock-mode t nil (font-lock))
 '(icicle-reminder-prompt-flag 5)
 '(js2-bounce-indent-p t)
 '(js2-highlight-level 3)
 '(js2-mode-escape-quotes nil)
 '(js2-strict-inconsistent-return-warning nil)
 '(js2-strict-missing-semi-warning nil)
 '(minimap-always-recenter nil)
 '(minimap-display-semantic-overlays t)
 '(mojo-build-directory "~/Projects/brighthouse/webOS/build")
 '(mojo-debug nil)
 '(mojo-project-directory "~/Projects/brighthouse/webOS")
 '(remote-shell-program "/usr/bin/ssh")
 '(save-place t nil (saveplace))
 '(scroll-bar-mode nil)
 '(shell-file-name "/bin/zsh")
 '(show-paren-mode t nil (paren))
 '(tool-bar-mode nil))

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
 '(minimap-font-face ((default (:height 30 :family "DejaVu Sans Mono")) (nil nil))))

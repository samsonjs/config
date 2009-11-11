; emacs "shift-mark" functionality
;
; Allows you to mark a region by holding down the Shift modifier key
; and moving the cursor.
; Source: http://www.cs.ucsb.edu/~matz/study/EmacsShiftMark.html
;
; written by matz"a"cs.ucsb.edu, March 10th, 1998

(defun shift-mark (cmd)
  "Expands marked region to the point (position of cursor) after executing
command 'cmd'. If no region is marked, we mark one first."
  (interactive "_a")
  (if (not (region-active-p))
      (progn (set-mark-command nil)
	     (command-execute cmd))
  (command-execute cmd)
))

(defun shift-mark-forward-char ()
  (interactive)
  (shift-mark 'forward-char)
)

(defun shift-mark-backward-char ()
  (interactive)
  (shift-mark 'backward-char)
)

(defun shift-mark-forward-word ()
  (interactive)
  (shift-mark 'forward-word)
)

(defun shift-mark-backward-word ()
  (interactive)
  (shift-mark 'backward-word)
)

(defun shift-mark-forward-paragraph ()
  (interactive)
  (shift-mark 'forward-paragraph)
)

(defun shift-mark-backward-paragraph ()
  (interactive)
  (shift-mark 'backward-paragraph)
)

(defun shift-mark-previous-line ()
  (interactive)
  (shift-mark 'previous-line)
)

(defun shift-mark-next-line ()
  (interactive)
  (shift-mark 'next-line)
)

(defun backspace-delete-marked-region ()
  (interactive)
					;  (zmacs-region-stays t)
  (if (region-active-p)
      (kill-region (mark) (point))
    (delete-backward-char 1)
    )
)

(global-set-key '(shift right)      'shift-mark-forward-char)
(global-set-key '(shift left)    'shift-mark-backward-char)
(global-set-key '(shift up)    'shift-mark-previous-line)
(global-set-key '(shift down)    'shift-mark-next-line)
(global-set-key '(shift control right)    'shift-mark-forward-word)
(global-set-key '(shift control left)    'shift-mark-backward-word)
(global-set-key '(shift control up)    'shift-mark-backward-paragraph)
(global-set-key '(shift control down)    'shift-mark-forward-paragraph)
(global-set-key '(shift backspace)    'backspace-delete-marked-region)
(global-set-key '(control backspace)    'backspace-delete-marked-region)
(global-set-key '(shift control backspace)    'backspace-delete-marked-region)
(global-set-key '(del)    'backspace-delete-marked-region)

(global-set-key '(control left) 'backward-word)
(global-set-key '(control right) 'forward-word)
(global-set-key '(control up) 'backward-paragraph)
(global-set-key '(control down) 'forward-paragraph)
(global-set-key '(f27) 'beginning-of-line)  ;HOME
(global-set-key '(f33) 'end-of-line)        ;END

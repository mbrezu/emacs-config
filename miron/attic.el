
;; my code
(defun modify-current-number (func)
  (let ((num_val (string-to-number (thing-at-point 'word))))
    (backward-word 1)
    (kill-word 1)
    (insert (number-to-string (funcall func num_val)))))

(defun inc-current-number ()
  "increments the number under the cursor"
  (interactive)
  (modify-current-number #'1+))

(defun dec-current-number ()
  "decrements the number under the cursor"
  (interactive)
  (modify-current-number #'1-))

(global-set-key [f12] 'inc-current-number)
(global-set-key [S-f12] 'dec-current-number)

(defun tagize ()
  "
Will treat the current word as a tag, delete it,
then reinsert it as an HTML/XML tag together with its closing pair
"
  (interactive)
  (let ((current-word (thing-at-point 'word)))
    (backward-word 1)
    (kill-word 1)
    (let ((open-tag (format "<%s>" current-word))
          (close-tag (format "</%s>" current-word)))
      (insert open-tag)
      (save-excursion
        (insert close-tag)))))

(defmacro maybe-next-line (fun count)
  (let ((counte (make-symbol "count")))
    `(let ((,counte ,count))
       (if ,counte
           (if (> ,counte 1)
               (progn
                 (forward-line)
                 (,fun (1- ,counte))))))))

(defun c++-comment-line (&optional count)
  "comments a line C++ style"
  (interactive "p")
  (save-excursion
    (beginning-of-line)
    (insert "//"))
  (maybe-next-line c++-comment-line count))

(defun c++-uncomment-line (&optional count)
  "uncomments a line C++ style"
  (interactive "p")
  (save-excursion
    (beginning-of-line)
    (if (equal (char-to-string (char-after)) "/")
        (delete-char 2)))
  (maybe-next-line c++-uncomment-line count))

(defun dup-line ()
  "duplicates the current line"
  (interactive)
  (save-excursion
    (beginning-of-line)
    (set-mark (point))
    (forward-line)
    (kill-ring-save (mark) (point))
    (yank)))

(global-set-key [f3] 'c++-comment-line)
(global-set-key [f4] 'c++-uncomment-line)
(global-set-key [f2] 'dup-line)
(global-set-key [f5] 'tagize)
(global-set-key [f10] 'join-line)

;;; Use "C-c %" to jump to the matching parenthesis.
(defun goto-match-paren (arg)
  "Go to the matching parenthesis if on parenthesis, otherwise insert
the character typed."
  (interactive "p")
  (cond ((looking-at "\\s\(") (forward-list 1) (backward-char 1))
        ((looking-at "\\s\)") (forward-char 1) (backward-list 1))
        (t                    (self-insert-command (or arg 1))) ))
(global-set-key (kbd "C-c %") `goto-match-paren)



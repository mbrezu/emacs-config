

(defun comedit-log-text (text)
  "Append the text to the *log* buffer. The *log* buffer is
created if missing."
  (save-current-buffer
    (set-buffer (get-buffer-create "*log*"))
    (save-excursion
      (goto-char (point-max))
      (insert "\n")
      (insert text))))

(defun comedit-clear-log ()
  "Clears the contents of the *log* buffer. The *log* buffer is
  created if missing."
  (save-current-buffer
    (set-buffer (get-buffer-create "*log*"))
    (erase-buffer)))

(defun comedit-get-line ()
  (save-excursion
    (beginning-of-line)
    (let ((start-line (point)))
      (end-of-line)
      (let ((end-line (point)))
        (buffer-substring-no-properties start-line end-line)))))

(defun comedit-get-lines-in-selection (start end)
  "Return an array filled with the lines that intersect the
region."
  (interactive "r")
  (let ((result nil))
    (save-excursion
      (goto-char start)
      (while (< (point) end)
        (push (comedit-get-line) result)
        (forward-line)))
    (reverse result)))

(defun comedit-get-max-prefix-length (lines &optional good-prefix-length)
  (unless good-prefix-length
    (setf good-prefix-length 0))
  (let* ((try-prefix-length (1+ good-prefix-length))
         (prefixes (mapcar (lambda (str)
                             (substring str 0 (min (length str)
                                                   try-prefix-length)))
                           lines)))
    (if (every (lambda (str)
                 (string= str (car prefixes)))
               prefixes)
        (comedit-get-max-prefix-length lines try-prefix-length)
        good-prefix-length)))

(defvar *comedit-comment-buffers** (make-hash-table :test 'equal))

(defun comedit-kbh ()
  (let ((buffer-info (gethash (buffer-name) *comedit-comment-buffers**)))
    (when buffer-info
      (let ((buffer-prefix (elt buffer-info 0))
            (original-buffer-name (elt buffer-info 1)))
        (remhash (buffer-name) *comedit-comment-buffers**)
        (let* ((lines (comedit-get-lines-in-selection (point-min) (point-max)))
               (prefixed-lines (mapcar (lambda (str)
                                         (concat buffer-prefix str))
                                       lines)))
          (delete-region (point-min) (point-max))
          (dolist (line prefixed-lines)
            (insert line)
            (insert "\n")))
        (pop-to-buffer original-buffer-name)))))

(add-hook 'kill-buffer-hook 'comedit-kbh)

;; This is a comment.  I'm testing the function below.
(defun comedit-create-comment-buffer (start end)
  "

Creates an indirect buffer based on the current buffer. It
narrows to the region in the old buffer, removes the longest
common prefix from lines (presumably single line comment markers)
and switches to markdown mode for the indirect buffer. A kill
buffer hook will re-add the common prefix to the lines when the
comments buffer is killed.
"
  (interactive "r")
  (let* ((lines (comedit-get-lines-in-selection start end))
         (max-prefix-length (comedit-get-max-prefix-length lines))
         (prefix (substring (car lines) 0 max-prefix-length))
         (cut-lines (mapcar (lambda (str)
                              (substring str max-prefix-length))
                            lines)))
    (let* ((original-buffer-name (buffer-name))
           (comment-buffer-name (concat "comments-for-" original-buffer-name)))
      (clone-indirect-buffer comment-buffer-name t t)
      (pop-to-buffer comment-buffer-name)
      (narrow-to-region start end)
      (delete-region (point-min) (point-max))
      (goto-char (point-min))
      (dolist (line cut-lines)
        (insert line)
        (insert "\n"))
      (goto-char (point-min))
      (puthash comment-buffer-name
               (list prefix original-buffer-name)
               *comedit-comment-buffers**)
      (markdown-mode))))

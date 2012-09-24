;; -*- mode: emacs-lisp; lexical-binding: t; -*-

(defun comedit-log-text (text)
  "Append the text to the *comedit-log* buffer. The *comedit-log*
buffer is created if missing."
  (save-current-buffer
    (set-buffer (get-buffer-create "*comedit-log*"))
    (save-excursion
      (goto-char (point-max))
      (insert "\n")
      (insert text))))

(defun comedit-clear-log ()
  "Clears the contents of the *comedit-log* buffer. The
  *comedit-log* buffer is created if missing."
  (save-current-buffer
    (set-buffer (get-buffer-create "*comedit-log*"))
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

(defun comedit-process-comments (lines)
  "Processes comments by removing the 'comment string'
  (e.g. '//' for C/C++) and indentation from comments in
  LINES (it is assumed that LINES is the list of lines containing
  an continous block of comments, possibly interrupted by empty
  lines).

  The 'comment string' is determined as the continuous non-space
  prefix common to all non-empty lines (after removing
  indentation). A line containing only white space is considered
  empty. The comment string may be preceded by white
  space (indentation).

  The function returns three values:

   * the indentation level of the comment (number of spaces
     between the beginning of the line and the comment string),

   * the comment string,

   * the lines with the leading white space and comment string
     removed."
  (let* ((non-empty-lines (remove-if-not (lambda (line)
                                           (string-match "[^ \t]+" line))
                                         lines))
         (indentation-level (comedit-get-max-prefix-length
                             non-empty-lines
                             (lambda (prefix) (string-match "^[ \t]*$" prefix))))
         (unindented-non-empty-lines (mapcar (lambda (line)
                                               (substring line indentation-level))
                                             non-empty-lines))
         (comment-string-length (comedit-get-max-prefix-length
                                 unindented-non-empty-lines
                                 (lambda (prefix)
                                   (not (string-match "[ \t]+[^ \t]+" prefix)))))
         (comment-string (substring (first unindented-non-empty-lines)
                                    0
                                    comment-string-length))
         (comment-body-indentation (+ indentation-level comment-string-length)))
    (values indentation-level
            comment-string
            (mapcar (lambda (line)
                      (if (> (length line) comment-body-indentation)
                          (substring line comment-body-indentation)
                          ""))
                    lines))))

(defun comedit-get-max-prefix-length (lines predicate &optional good-prefix-length)
  "Returns the length of the longest common prefix of LINES. The
prefix is also validated by PREDICATE."
  (unless good-prefix-length
    (setf good-prefix-length 0))
  (let* ((try-prefix-length (1+ good-prefix-length))
         (prefixes (mapcar (lambda (str)
                             (substring str 0 (min (length str)
                                                   try-prefix-length)))
                           lines)))
    (if (and (every (lambda (str)
                      (and (string= str (car prefixes))
                           (funcall predicate str)))
                    prefixes)
             (< good-prefix-length (length (first lines))))
        (comedit-get-max-prefix-length lines predicate try-prefix-length)
        good-prefix-length)))

(defvar *comedit-comment-buffers* (make-hash-table :test 'equal))

(defun comedit-kbh ()
  "Kill buffer hook for comedit: when a buffer is killed, the
  *COMEDIT-COMMENT-BUFFERS* hash is searched for an entry
  corresponding to the current buffer name. If an entry is found,
  uses the information in the entry to replace the original
  comment in the original buffer with the content of the comment
  buffer, with indentation and comment string prependend on each
  line; finally marks the original buffer as writable.

  Empty lines in the comment buffer are not transformed in any
  way."
  (let ((buffer-info (gethash (buffer-name) *comedit-comment-buffers*)))
    (when buffer-info
      (let* ((original-buffer-name (elt buffer-info 0))
             (indentation-level (elt buffer-info 1))
             (comment-string (elt buffer-info 2))
             (start (elt buffer-info 3))
             (end (elt buffer-info 4))
             (buffer-prefix (concat (make-string indentation-level ?\s)
                                    comment-string)))
        (remhash (buffer-name) *comedit-comment-buffers*)
        (delete-trailing-whitespace)
        (let* ((lines (comedit-get-lines-in-selection (point-min) (point-max)))
               (prefixed-lines (mapcar (lambda (str)
                                         (if (string-match "^[ \t]*$" str)
                                             ""
                                             (concat buffer-prefix str)))
                                       lines)))
          (with-current-buffer original-buffer-name
            (setf buffer-read-only nil)
            (delete-region start end)
            (goto-char start)
            (dolist (line prefixed-lines)
              (insert line)
              (insert "\n"))))
        (pop-to-buffer original-buffer-name)))))

(add-hook 'kill-buffer-hook 'comedit-kbh)

(defun comedit-create-comment-buffer (start end)
  "Creates an indirect buffer based on the current buffer. It
  narrows to the region in the old buffer, removes the longest
  common prefix from lines (presumably single line comment
  markers) and switches to markdown mode for the indirect
  buffer. A kill buffer hook will re-add the common prefix to the
  lines when the comments buffer is killed.

  The original buffer is marked as read-only until the comment
  buffer is killed (so the original comment block is not changed
  or moved)."
  (interactive "r")
  (let* ((lines (comedit-get-lines-in-selection start end))
         (original-buffer-name (buffer-name))
         (comment-buffer-name (concat "comments-for-" original-buffer-name)))
    (multiple-value-bind (indentation-level comment-string trimmed-lines)
        (comedit-process-comments lines)
      (setf buffer-read-only t)
      (get-buffer-create comment-buffer-name)
      (pop-to-buffer comment-buffer-name)
      (erase-buffer)
      (dolist (line trimmed-lines)
        (insert line)
        (insert "\n"))
      (goto-char (point-min))
      (puthash comment-buffer-name
               (list original-buffer-name
                     indentation-level
                     comment-string
                     start
                     end)
               *comedit-comment-buffers*)
      (markdown-mode))))

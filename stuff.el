;; pretty pointless efforts to duplicate M-/ without knowing about it
;; good for learning elisp, though
;; Miron Brezuleanu, Oct 19, 2007

(defun forward-uword ()
  "like forward-word, but underscores are considered part of the word"
  (interactive)
  (if (not (forward-word))
      nil
      (cond ((looking-at "_+\\w") (forward-uword))
            ((looking-at "_+") (search-forward-regexp "_+"))
            (t t))))

(defun repeat-search-backward-regexp (regexp)
  (while (looking-back regexp)
    (search-backward-regexp regexp)))
          
(defun backward-uword ()
  "like forward-word, but underscores are considered part of the word"
  (interactive)
  (if (not (backward-word))
      nil
      (cond ((looking-back "\\w_+") (backward-uword))
            ((looking-back "_+") (repeat-search-backward-regexp "_+"))
            (t t))))

(defun current-uword ()
  "returns the current word with underscores as a string"
  (interactive)
  (let ((end (point))
        (beg (save-excursion
               (backward-uword)
               (point))))
    (buffer-substring-no-properties beg end)))

(defun list-words ()
  "list the words in the buffer in a hash table, except the word at point"
  (interactive)
  (let ((words '())
        (wstart 0)
        (wend 0))      
    (save-excursion
      (goto-char (point-min))
      (while (forward-uword)
        (setq wend (point))
        (backward-uword)
        (setq wstart (point))
        (forward-uword)
        (setq words (cons (buffer-substring-no-properties wstart wend)
                          words))))
    (let ((result (makehash 'equal))
          (curword (current-uword)))
      (mapcar (lambda (w) (if (not (string= w curword))
                              (puthash w nil result)))
              words)
      (message curword)
      result)))

(defun words-complete-symbol ()
  "Perform completion on words from current buffer (ripped and
   transformed lisp-complete-symbol"
  (interactive)
  (let ((window (get-buffer-window "*Completions*" 0)))
    (if (and (eq last-command this-command)
             window (window-live-p window) (window-buffer window)
             (buffer-name (window-buffer window)))
        ;; If this command was repeated, and
        ;; there's a fresh completion window with a live buffer,
        ;; and this command is repeated, scroll that window.
        (with-current-buffer (window-buffer window)
          (if (pos-visible-in-window-p (point-max) window)
              (set-window-start window (point-min))
              (save-selected-window
                (select-window window)
                (scroll-up))))

        ;; Do completion.
        (let* ((end (point))
               (beg (save-excursion
                      (backward-uword)
                      (point)))
               (pattern (current-uword))
               (words (list-words))
               (completion (try-completion pattern words)))
          (cond ((eq completion t))
                ((null completion)
                 (message "Can't find completion for \"%s\"" pattern)
                 (ding))
                ((not (string= pattern completion))
                 (delete-region beg end)
                 (insert completion)
                 ;; Don't leave around a completions buffer that's out of date.
                 (let ((win (get-buffer-window "*Completions*" 0)))
                   (if win (with-selected-window win (bury-buffer)))))
                (t
                 (let ((minibuf-is-in-use
                        (eq (minibuffer-window) (selected-window))))
                   (unless minibuf-is-in-use
                     (message "Making completion list..."))
                   (let ((list (all-completions pattern words)))
                     (setq list (sort list 'string<))
                     (let (new)
                       (while list
                         (setq new (cons (if (fboundp (intern (car list)))
                                             (list (car list) " <f>")
                                             (car list))
                                         new))
                         (setq list (cdr list)))
                       (setq list (nreverse new)))
                     (if (> (length list) 1)
                         (with-output-to-temp-buffer "*Completions*"
                           (display-completion-list list pattern))
                         ;; Don't leave around a completions buffer that's
                         ;; out of date.
                         (let ((win (get-buffer-window "*Completions*" 0)))
                           (if win (with-selected-window win (bury-buffer))))))
                   (unless minibuf-is-in-use
                     (message "Making completion list...%s" "done")))))))))

(global-set-key "\C-xp" 'words-complete-symbol)

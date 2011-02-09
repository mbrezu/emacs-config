;;; show-functions.el --- list functions in a buffer

;; Copyright (C) 2003 by Aurélien Tisné
;; Author: Aurélien Tisné <aurelien.tisne@free.fr>
;; Keywords: convenience

;; This file is not part of GNU Emacs.

;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License
;; as published by the Free Software Foundation; either version 2
;; of the License, or (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program; if not, write to the Free Software
;; Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

;;; Commentary:
;; This package build a temporary buffer containing the list of all 
;; functions defined in the visited buffer.
;; You should provide the pattern of the function definition in
;; parameter of the main function. The default pattern is the
;; declaration of elisp function '(defun'.
;; You can provide the pattern of the declaration of other items.
;; For instance 'class' to list java classes.

;;; Code:

(require 'wid-edit)                   ; to use widgets (part of GNU emacs)

(defvar show-functions-map nil 
  "Keymap for show-functions temporary buffer.")

(if show-functions-map
    ()
  (setq show-functions-map (make-sparse-keymap))
  (suppress-keymap show-functions-map t)
  (define-key show-functions-map "\r" 'widget-button-press)
  (define-key show-functions-map "q" 'kill-current-buffer)
  (define-key show-functions-map [down-mouse-1] 'widget-button-click)
  (set-keymap-parent show-functions-map widget-keymap)
)

(defvar previous-buffer nil)

;;;###autoload
(defun show-functions-in-buffer (&optional pattern)
  "Show the functions defined in the current buffer.

PATTERN is the function declaration depending on language.
Default is elisp one: (defun."
  (interactive "sFunction declaration (default '(defun'): ")
  (if (or (not pattern) (string= pattern "")) (setq pattern "(defun"))
  ;; build the functions buffer
  (let ((current (current-buffer))      ; buffer where to search
        (buffer (get-buffer-create "*Function Definitions*"))
        (nb 0)                          ; count found occurences
        (fct-name nil)                  ; name of the found function
        (fct-loc nil))                  ; location of the found function
    (setq previous-buffer (current-buffer))
    (save-excursion
      (set-buffer buffer)
      (let ((inhibit-read-only t))
        (erase-buffer))
      (widget-insert "Click or type RET on a function to explore it. Click on Cancel or type \"q\" to quit.\n\n")
      (set-buffer current)

      (save-restriction
        (widen)
        (goto-char (point-min))
        (while (re-search-forward (concat pattern " \\([^(|^ ]*\\)") nil t)
          (progn
            (setq nb (1+ nb))
            (setq fct-name (match-string 1))
            (setq fct-loc (point))
            (set-buffer buffer)
            ;; insert hyperlink to the source code
            (widget-create 'push-button
                           :button-face 'default
                           :tag fct-name
                           :value (cons current fct-loc)
                           :help-echo (concat "Jump to " fct-name)
                           :notify (lambda (widget &rest ignore)
                                     (pop-to-buffer (car (widget-value widget)))
                                     (goto-char (cdr (widget-value widget)))))
            (widget-insert "\n")
            (set-buffer current))))

      (set-buffer buffer)
      (widget-insert (format "\n%d occurence%s found in %s\n" nb
                             (if (> nb 1) "s" "") (buffer-name current)))
      (widget-create 'push-button
                     :tag "Cancel"
                     :notify '(lambda (&rest ignore)
                                (kill-buffer (current-buffer))
                                (pop-to-buffer previous-buffer)))
      (use-local-map show-functions-map)
      (setq buffer-read-only t))
    (pop-to-buffer buffer)))

(defun kill-current-buffer ()
  (interactive)
  "  "
  (kill-buffer (current-buffer))
  (pop-to-buffer previous-buffer))

(provide 'show-functions)


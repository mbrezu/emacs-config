
;;(set-default-font "Terminus-15:bold")
;;(set-default-font "Terminus-17:bold")
;;(set-default-font "Anonymous Pro-15")
;;(set-default-font "Inconsolata-16.5")
;;(set-default-font "Droid Sans Mono-14")
;;(set-default-font "Droid Sans Mono Dotted-12")
;; (set-default-font "Linux Libertine Mono-12")
(set-default-font "Anka/Coder Condensed-14")
;;(set-default-font "Droid Sans Mono Slashed-14")
;;(set-default-font "Liberation Mono-14")
;;(set-default-font "Liberation Mono-13")
;;(set-default-font "Mono-14")
;;(set-default-font "Courier New-14")

(global-set-key "\C-x\C-m" 'execute-extended-command)
(global-set-key "\C-c\C-m" 'execute-extended-command)
(global-set-key "\C-w" 'backward-kill-word)
(global-set-key "\C-x\C-k" 'kill-region)
(global-set-key "\C-c\C-k" 'kill-region)

(setq x-select-enable-clipboard t)

;; slime stuff
(setq slime-lisp-implementations
      '((sbcl ("/usr/local/bin/sbcl" "--dynamic-space-size" "2000") :coding-system utf-8-unix)
        (ccl ("/home/miron/tmp/ccl/lx86cl") :coding-system utf-8-unix)
        (ccl64 ("/home/miron/tmp/ccl/lx86cl64") :coding-system utf-8-unix)
        (clisp ("/usr/bin/clisp") :coding-system utf-8-unix)
        (ecl ("/usr/local/bin/ecl") :coding-system utf-8-unix)))

(setq slime-load-failed-fasl 'always)
(setq slime-compile-file-options '(:fasl-directory "~/tmp/slime-fasls/"))
(make-directory "~/tmp/slime-fasls/" t)

(load (expand-file-name "~/quicklisp/slime-helper.el"))
(global-set-key [C-tab] `slime-fuzzy-complete-symbol)
(setq browse-url-browser-function 'browse-url-generic
      browse-url-generic-program "/usr/bin/google-chrome")
;; (setq browse-url-browser-function 'browse-url-generic
;;       browse-url-generic-program "/usr/bin/firefox")
;; (setq browse-url-browser-function 'browse-url-generic
;;       browse-url-generic-program "/usr/bin/opera")
(load (expand-file-name "~/quicklisp/clhs-use-local.el") t)
(set-language-environment "UTF-8")
(setq slime-net-coding-system 'utf-8-unix)

(setq load-path (cons  "~/emacs" load-path))
(setq load-path (cons  "~/emacs/icicles" load-path))
(setq load-path (cons  "~/emacs/clojure" load-path))
(setq load-path (cons  "~/emacs/golang" load-path))
(setq load-path (cons  "~/emacs/miron" load-path))
(setq load-path (cons  "~/emacs/auto-complete-1.3.1" load-path))

(tool-bar-mode -1)
(menu-bar-mode -1)
(scroll-bar-mode -1)

;; General stuff

;; Inhibit the splash screen.
(setq inhibit-splash-screen t)

;; Disable backup (I use git anyway).
(setq backup-inhibited t)

(setq-default indent-tabs-mode nil)
(global-font-lock-mode 1)
(put 'if 'lisp-indent-function 3)

(add-hook 'font-lock-mode-hook
          (function
           (lambda ()
             (setq font-lock-keywords
                   (append font-lock-keywords
                           '(("\t+" (0 'my-tab-face t))
                             ("^.\\{101,\\}$" (0 'my-long-line-face t))
                             ("[ \t]+$"      (0 'my-trailing-space-face t))))))))

;; paredit mode
(load "paredit.el")
(autoload 'paredit-mode "paredit"
  "Minor mode for pseudo-structurally editing Lisp code." t)
(add-hook 'emacs-lisp-mode-hook       (lambda () (paredit-mode +1)))
(add-hook 'lisp-mode-hook             (lambda () (paredit-mode +1)))
(add-hook 'lisp-interaction-mode-hook (lambda () (paredit-mode +1)))
(require 'eldoc) ; if not already loaded
(eldoc-add-command
 'paredit-backward-delete
 'paredit-close-round)

(defun paredit-space-for-delimiter-predicate-common-lisp (endp delimiter)
  (not (eq (char-syntax delimiter) ?\")))

(add-to-list 'paredit-space-for-delimiter-predicates
             'paredit-space-for-delimiter-predicate-common-lisp)

(add-hook 'slime-repl-mode-hook (lambda () (paredit-mode +1)))

;; Stop SLIME's REPL from grabbing DEL,
;; which is annoying when backspacing over a '('
(defun override-slime-repl-bindings-with-paredit ()
  (define-key slime-repl-mode-map
    (read-kbd-macro paredit-backward-delete-key) nil))
(add-hook 'slime-repl-mode-hook 'override-slime-repl-bindings-with-paredit)

(defvar electrify-return-match
  "[\]}\)\"]"
  "If this regexp matches the text after the cursor, do an \"electric\"
  return.")

(defun electrify-return-if-match (arg)
  "If the text after the cursor matches `electrify-return-match' then
  open and indent an empty line between the cursor and the text.  Move the
  cursor to the new line."
  (interactive "P")
  (let ((case-fold-search nil))
    (if (looking-at electrify-return-match)
        (save-excursion (newline-and-indent)))
    (newline arg)
    (indent-according-to-mode)))

;; Using local-set-key in a mode-hook is a better idea.
(global-set-key (kbd "RET") 'electrify-return-if-match)

;; end of paredit stuff


;; ffap
;;(load "ffap.el")

;; icicles
(load-library "icicles")

(setq search-highlight           t)     ; Highlight search object
(setq query-replace-highlight    t)     ; Highlight query object
(setq mouse-sel-retain-highlight t)     ; Keep mouse high-lightening
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(column-number-mode t)
 '(custom-safe-themes (quote ("54d1bcf3fcf758af4812f98eb53b5d767f897442753e1aa468cfeb221f8734f9" "baed08a10ff9393ce578c3ea3e8fd4f8c86e595463a882c55f3bd617df7e5a45" "1440d751f5ef51f9245f8910113daee99848e2c0" "485737acc3bedc0318a567f1c0f5e7ed2dfde3fb" default)))
 '(icicle-reminder-prompt-flag 4)
 '(org-agenda-files (quote ("~/work/Zarkon/plan.org")))
 '(safe-local-variable-values (quote ((Package . CCL) (Package . FLEXI-STREAMS) (Package . CL-PPCRE) (Package . CL-FAD) (Package . DRAKMA) (Package . CL-WHO) (package . RFC2388) (Package . CL-USER) (Base . 10) (Package . HUNCHENTOOT) (Syntax . COMMON-LISP) (package . puri) (Syntax . ANSI-Common-Lisp))))
 '(save-place t nil (saveplace))
 '(show-paren-mode t)
 '(slime-backend "swank-loader.lisp" t))

;; (autoload 'js2-mode "js2" nil t)
;; (add-to-list 'auto-mode-alist '("\\.js$" . js2-mode))

(server-start)
(setq visible-bell t)

(ido-mode)

(autoload 'markdown-mode "markdown-mode.el"
  "Major mode for editing Markdown files" t)
(setq auto-mode-alist
      (cons '("\\.text" . markdown-mode) auto-mode-alist))

;; Auto revert files changed from another editor
(global-auto-revert-mode t)

;; Cleanup buffer/region
(defun region-active-p ()
  (and mark-active transient-mark-mode))

(defun clean-up-buffer-or-region ()
  "Untabifies, indents and deletes trailing whitespace from buffer or region."
  (interactive)
  (save-excursion
    (unless (region-active-p)
      (mark-whole-buffer))
    (untabify (region-beginning) (region-end))
    (indent-region (region-beginning) (region-end))
    (save-restriction
      (narrow-to-region (region-beginning) (region-end))
      (delete-trailing-whitespace))))

(global-set-key (kbd "C-c n") 'clean-up-buffer-or-region)

;; Toggle between Markdown and Literate Haskell modes.
(global-set-key (kbd "C-c m") 'markdown-mode)

;; mic-paren
(require 'mic-paren)
(paren-activate)

(global-set-key (kbd "C-c s") 'slime-selector)

;; w3m stuff
;;(setq browse-url-browser-function 'w3m-browse-url)
(autoload 'w3m-browse-url "w3m" "Ask a WWW browser to show a URL." t)
;; optional keyboard short-cut
(global-set-key "\C-xm" 'browse-url-at-point)

(setq w3m-use-cookies t)

(setq w3m-coding-system 'utf-8
      w3m-file-coding-system 'utf-8
      w3m-file-name-coding-system 'utf-8
      w3m-input-coding-system 'utf-8
      w3m-output-coding-system 'utf-8
      w3m-terminal-coding-system 'utf-8)

;; end of w3m stuff

;; Show functions stuff.
(require 'show-functions)

(put 'downcase-region 'disabled nil)

(put 'upcase-region 'disabled nil)

;; shell stuff
(ansi-color-for-comint-mode-on)

;; anything.el
(require 'anything)

(defun copy-full-path-to-kill-ring ()
  "copy buffer's full path to kill ring"
  (interactive)
  (when buffer-file-name
    (kill-new (file-truename buffer-file-name))))

(defun toggle-fullscreen (&optional f)
  (interactive)
  (let ((current-value (frame-parameter nil 'fullscreen)))
    (set-frame-parameter nil 'fullscreen
                         (if (equal 'fullboth current-value)
                             (if (boundp 'old-fullscreen) old-fullscreen nil)
                             (progn (setq old-fullscreen current-value)
                                    'fullboth)))))
(global-set-key [f11] 'toggle-fullscreen)

;; Color themes.
(setq load-path (cons "~/emacs/color-theme-6.6.0" load-path))
(require 'color-theme)

(color-theme-initialize)
(color-theme-pierson)

(put 'narrow-to-region 'disabled nil)

;; lispdoc

(defun lispdoc ()
  "searches lispdoc.com for SYMBOL, which is by default the symbol
currently under the curser"
  (interactive)
  (let* ((word-at-point (word-at-point))
         (symbol-at-point (symbol-at-point))
         (default (symbol-name symbol-at-point))
         (inp (read-from-minibuffer
               (if (or word-at-point symbol-at-point)
                   (concat "Symbol (default " default "): ")
                   "Symbol (no default): "))))
    (if (and (string= inp "")
             (not word-at-point)
             (not symbol-at-point))
        (message "you didn't enter a symbol!")
        (let ((search-type
               (read-from-minibuffer
                "full-text (f) or basic (b) search (default b)? ")))
          (browse-url (concat "http://lispdoc.com?q="
                              (if (string= inp "")
                                  default
                                  inp)
                              "&search="
                              (if (string-equal search-type "f")
                                  "full+text+search"
                                  "basic+search")))))))

(global-set-key (kbd "C-c l") 'lispdoc)

(defun romanian-kbd ()
  "Switch the keyboard to the input method for Romanian."
  (interactive)
  (set-input-method 'romanian-alt-prefix))

(defun english-kbd ()
  "Switch the keyboard to the default method"
  (interactive)
  (inactivate-input-method))

(global-set-key (kbd "C-c r") 'romanian-kbd)
(global-set-key (kbd "C-c e") 'english-kbd)

(require 'window-numbering)
(window-numbering-mode 1)

;; recentf

(require 'recentf)
(recentf-mode 1)
(setq recentf-max-menu-items 250)
(global-set-key "\C-x\ \C-r" 'recentf-open-files)

;; dedicate windows

;; Toggle window dedication

(defun toggle-window-dedicated ()
  "Toggle whether the current active window is dedicated or not"
  (interactive)
  (message
   (if (let (window (get-buffer-window (current-buffer)))
         (set-window-dedicated-p window
                                 (not (window-dedicated-p window))))
       "Window '%s' is dedicated"
       "Window '%s' is normal")
   (current-buffer)))

(global-set-key (kbd "C-c p") 'toggle-window-dedicated)

;; Bash completion
;; (require 'shell-command)
;; (shell-command-completion-mode)
(require 'bash-completion)
(bash-completion-setup)

;; Transpose buffers
(defun transpose-buffers (arg)
  "Transpose the buffers shown in two windows."
  (interactive "p")
  (let ((selector (if (>= arg 0) 'next-window 'previous-window)))
    (while (/= arg 0)
      (let ((this-win (window-buffer))
            (next-win (window-buffer (funcall selector))))
        (set-window-buffer (selected-window) next-win)
        (set-window-buffer (funcall selector) this-win)
        (select-window (funcall selector)))
      (setq arg (if (plusp arg) (1- arg) (1+ arg))))))

(global-set-key (kbd "C-c t") 'transpose-buffers)

(defun show-buffer-file-name ()
  (interactive)
  (message (buffer-file-name)))

(global-set-key (kbd "C-c b") 'show-buffer-file-name)

(require 'dirtree)

;;; SQL formatter
(eval-after-load "sql"
  '(load-library "sql-indent"))

;;; Fix texts in Romanian (Emacs's input method inserts characters
;;; with cedillas, the correct versions for Romanian are characters
;;; with commas).
(defun fixro ()
  (interactive)
  (subst-char-in-region (point-min) (point-max) ?\ş ?\ș)
  (subst-char-in-region (point-min) (point-max) ?\Ş ?\Ș)

  (subst-char-in-region (point-min) (point-max) ?\ţ ?\ț)
  (subst-char-in-region (point-min) (point-max) ?\Ţ ?\Ț))

;;; Session switching from
;;; http://stackoverflow.com/questions/847962

(defvar my-desktop-session-dir
  (concat (getenv "HOME") "/.emacs.d/desktop-sessions/")
  "*Directory to save desktop sessions in")

(defvar my-desktop-session-name-hist nil
  "Desktop session name history")

(defun my-desktop-save (&optional name)
  "Save desktop with a name."
  (interactive)
  (unless name
    (setq name (my-desktop-get-session-name "Save session as: ")))
  (make-directory (concat my-desktop-session-dir name) t)
  (desktop-save (concat my-desktop-session-dir name) t))

(defun my-desktop-read (&optional name)
  "Read desktop with a name."
  (interactive)
  (unless name
    (setq name (my-desktop-get-session-name "Load session: ")))
  (desktop-read (concat my-desktop-session-dir name)))

(defun my-desktop-get-session-name (prompt)
  (completing-read prompt (and (file-exists-p my-desktop-session-dir)
                               (directory-files my-desktop-session-dir))
                   nil nil nil my-desktop-session-name-hist))

(defun join-line-below ()
  (interactive)
  (save-excursion
    (forward-line)
    (join-line)))

(global-set-key (kbd "C-c j") 'join-line-below)

;; D language
(autoload 'd-mode "d-mode" "Major mode for editing D code." t)
(add-to-list 'auto-mode-alist '("\\.d[i]?\\'" . d-mode))

;; Subword mode
(add-hook 'find-file-hook 'subword-mode)

;; Comment edit
;; (load "comedit.el")
;; (global-set-key (kbd "C-c d") 'comedit-create-comment-buffer)

;; Golden ratio
(require 'golden-ratio)
(golden-ratio-enable)

;; GO language
(require 'go-mode-load)
(require 'go-autocomplete)
(require 'auto-complete-config)

;; Autopair
(require 'autopair)
;; Don't enable autopair globally because it interacts badly with
;; paredit.

;;(autopair-global-mode)



(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

;; packages to install
;; '(starter-kit
;;              starter-kit-lisp
;;              starter-kit-bindings
;;              starter-kit-eshell
;;              clojure-mode
;;              clojure-test-mode
;;              nrepl)

(require 'rust-mode)

(require 'linum)
(global-linum-mode 1)

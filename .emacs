
(global-set-key "\C-x\C-m" 'execute-extended-command)
(global-set-key "\C-c\C-m" 'execute-extended-command)
(global-set-key "\C-w" 'backward-kill-word)
(global-set-key "\C-x\C-k" 'kill-region)
(global-set-key "\C-c\C-k" 'kill-region)

(setq load-path (cons  "~/emacs" load-path))
(setq load-path (cons  "~/emacs/icicles" load-path))
(setq load-path (cons  "~/emacs/clojure" load-path))
;;(setq load-path (cons "~/emacs/ecb-2.32" load-path))

(tool-bar-mode -1)
(menu-bar-mode -1)
(scroll-bar-mode -1)

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


;; JavaScript stuff
;; (setq auto-mode-alist (append '(("\\.js$" . c-mode))
;;                               auto-mode-alist))

;;(add-to-list 'auto-mode-alist '("\\.js\\'" . javascript-mode))
;;(autoload 'javascript-mode "javascript" nil t)




;; PHP mode
(require 'php-mode)

(add-hook 'php-mode-user-hook 'turn-on-font-lock)

;;(add-hook 'php-mode-user-hook
;;          '(lambda () (define-abbrev php-mode-abbrev-table "ex" "extends")))

;; Python mode
(setq auto-mode-alist (cons '("\\.py$" . python-mode) auto-mode-alist))
(setq interpreter-mode-alist (cons '("python" . python-mode)
                                   interpreter-mode-alist))
(autoload 'python-mode "python-mode" "Python editing mode." t)

;; ;; Erlang mode stuff
;; (setq load-path (cons  "/usr/lib/erlang/lib/tools-2.5.5"
;;                        load-path))
;; (setq erlang-root-dir "/usr/lib/erlang")
;; (setq exec-path (cons "/usr/lib/erlang/bin" exec-path))
;; (require 'erlang-start)

;; C mode stuff
(setq c-default-style "bsd"
      c-basic-offset 4
      tab-width 4)

;; general stuff

;; inhibit the stupid splash screen
(setq inhibit-splash-screen t)

;;disable backup (I use svn anyways)
(setq backup-inhibited t)

(setq-default indent-tabs-mode nil)
(global-font-lock-mode 1)
(put 'if 'lisp-indent-function 3)

;; font size
(set-default-font "Terminus-12:bold")

;;; Use "%" to jump to the matching parenthesis.
(defun goto-match-paren (arg)
  "Go to the matching parenthesis if on parenthesis, otherwise insert
the character typed."
  (interactive "p")
  (cond ((looking-at "\\s\(") (forward-list 1) (backward-char 1))
        ((looking-at "\\s\)") (forward-char 1) (backward-list 1))
        (t                    (self-insert-command (or arg 1))) ))
(global-set-key "%" `goto-match-paren)

;; tpl files are smarty templates so use html-mode
(setq auto-mode-alist (append '(("\\.tpl$" . html-mode))
                              auto-mode-alist))

;; django templates mode
(load "django-mode.el")

;; region indent/dedent stuff

(defun indent-current-region-by (num-spaces)
  (indent-rigidly (region-beginning) (region-end) num-spaces))

(defun indent-current-region ()
  (interactive)
  (indent-current-region-by 4))

(defun dedent-current-region ()
  (interactive)
  (indent-current-region-by (- 4)))

(global-set-key [M-right]   'indent-current-region)

(global-set-key [M-left]    'dedent-current-region)
(custom-set-faces
  ;; custom-set-faces was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(default ((t (:inherit nil :stipple nil :background "white" :foreground "black" :inverse-video nil :box nil :strike-through nil :overline nil :underline nil :slant normal :weight normal :height 107 :width normal :foundry "unknown" :family "Liberation Mono"))))
 '(my-long-line-face ((((class color)) (:background "gray80"))) t)
 '(my-tab-face ((((class color)) (:background "grey80"))) t)
 '(my-trailing-space-face ((((class color)) (:background "gray80"))) t))


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

;; ffap
;;(load "ffap.el")

;; icicles
(load-library "icicles")

;; grep buffers
(load "grep-buffers.el")

;; ;; gnuserv
;; (gnuserv-start)
;; (setq gnuserv-frame (selected-frame))

;; ocaml mode
(setq auto-mode-alist (cons '("\\.ml\\w?" . tuareg-mode) auto-mode-alist))
(autoload 'tuareg-mode "tuareg" "Major mode for editing Caml code" t)
(autoload 'camldebug "camldebug" "Run the Caml debugger" t)

;; haskell mode
(load "~/emacs/haskell-mode-2.4/haskell-site-file")

(add-hook 'haskell-mode-hook 'turn-on-haskell-doc-mode)
(add-hook 'haskell-mode-hook 'turn-on-haskell-indent)
;;(add-hook 'haskell-mode-hook 'turn-on-haskell-simple-indent) 

;; CEDET
(load-file "~/emacs/cedet-1.0pre4/common/cedet.el")

;; Enabling various SEMANTIC minor modes.  See semantic/INSTALL for more ideas.
;; Select one of the following:

;; * This enables the database and idle reparse engines
;;(semantic-load-enable-minimum-features)

;; * This enables some tools useful for coding, such as summary mode
;;   imenu support, and the semantic navigator
(semantic-load-enable-code-helpers)

;; * This enables even more coding tools such as the nascent intellisense mode
;;   decoration mode, and stickyfunc mode (plus regular code helpers)
;; (semantic-load-enable-guady-code-helpers)

;; * This turns on which-func support (Plus all other code helpers)
;; (semantic-load-enable-excessive-code-helpers)

;; This turns on modes that aid in grammar writing and semantic tool
;; development.  It does not enable any other features such as code
;; helpers above.
;; (semantic-load-enable-semantic-debugging-helpers) 

;; ECB
;;(require 'ecb)
;;(setq ecb-auto-activate t)

;; ;; semantic
(setq semantic-load-turn-everything-on t)
(require 'semantic-load)
;;(global-semantic-show-dirty-mode -1)
(global-semantic-show-unmatched-syntax-mode -1)
;; autogenerated stuff

(setq search-highlight           t)     ; Highlight search object
(setq query-replace-highlight    t)     ; Highlight query object
(setq mouse-sel-retain-highlight t)     ; Keep mouse high-lightening
(custom-set-variables
  ;; custom-set-variables was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(column-number-mode t)
 '(debug-on-error t)
 '(icicle-reminder-prompt-flag 4)
 '(menu-bar-mode t)
 '(save-place t nil (saveplace))
 '(show-paren-mode t))


;; ecb
;;(ecb-activate)

(autoload 'js2-mode "js2" nil t)
(add-to-list 'auto-mode-alist '("\\.js$" . js2-mode))

(server-start)
(setq visible-bell t)
;; Clojure setup (including paredit)
(autoload 'clojure-mode "clojure-mode" "A major mode for Clojure" t)
(add-to-list 'auto-mode-alist '("\\.clj$" . clojure-mode))
;;(defun lisp-enable-paredit-hook () (paredit-mode 1))
;;(add-hook 'clojure-mode-hook 'lisp-enable-paredit-hook)

(ido-mode)

(autoload 'markdown-mode "markdown-mode.el"
  "Major mode for editing Markdown files" t)
(setq auto-mode-alist
      (cons '("\\.text" . markdown-mode) auto-mode-alist))

;; HaXe stuff
(require 'haxe-mode)
(defconst my-haxe-style
  '("java" (c-offsets-alist . ((case-label . +)
                               (arglist-intro . +)
                               (arglist-cont-nonempty . 0)
                               (arglist-close . 0)
                               (cpp-macro . 0))))
  "My haXe Programming Style")
(add-hook 'haxe-mode-hook
  (function (lambda () (c-add-style "haxe" my-haxe-style t))))
(add-hook 'haxe-mode-hook
          (function
           (lambda ()
             (setq tab-width 4)
             (setq indent-tabs-mode t)
             (setq fill-column 80)
             (local-set-key [(return)] 'newline-and-indent))))

;; FSharp stuff

(setq load-path (cons "~/emacs/fsharp" load-path))
(setq auto-mode-alist
      (cons '("\\.fs[iylx]?$" . fsharp-mode) auto-mode-alist))
(autoload 'fsharp-mode "fsharp" "Major mode for editing F# code." t)
(autoload 'run-fsharp "inf-fsharp" "Run an inferior F# process." t)

(setq inferior-fsharp-program "~/tmp/FSharp-1.9.9.9/bin/fsi.exe")
(setq fsharp-compiler "~/tmp/FSharp-1.9.9.9/bin/fsc.exe")

;; CamelCase stuff
(require 'camelCase)
(add-hook 'find-file-hook (function (lambda() (camelCase-mode 1))))

;; Auto revert files changed from another editor
(global-auto-revert-mode t)

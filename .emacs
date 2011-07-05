
(global-set-key "\C-x\C-m" 'execute-extended-command)
(global-set-key "\C-c\C-m" 'execute-extended-command)
(global-set-key "\C-w" 'backward-kill-word)
(global-set-key "\C-x\C-k" 'kill-region)
(global-set-key "\C-c\C-k" 'kill-region)

(setq x-select-enable-clipboard t)

;; slime stuff
(setq slime-lisp-implementations
      '((sbcl ("/usr/bin/sbcl") :coding-system utf-8-unix)
        (ccl ("/home/miron/tmp/ccl/lx86cl") :coding-system utf-8-unix)
        (clisp ("/usr/bin/clisp") :coding-system utf-8-unix)))
;; (add-hook 'lisp-mode-hook (lambda () (slime-mode t)))
;; (add-hook 'inferior-lisp-mode-hook (lambda () (inferior-slime-mode t)))
;; (require 'slime)
;; (require 'slime-fancy)
;; (require 'slime-banner)
;; (require 'slime-asdf)
;; (slime-banner-init)
;; (slime-asdf-init)
;; (setq slime-complete-symbol*-fancy t)
;; (setq slime-complete-symbol-function 'slime-fuzzy-complete-symbol)
;; (slime-setup '(slime-fancy slime-banner))

(load (expand-file-name "~/quicklisp/slime-helper.el"))
(global-set-key [C-tab] `slime-fuzzy-complete-symbol)
(setq browse-url-browser-function 'browse-url-generic
      browse-url-generic-program "/usr/bin/firefox")
(set-language-environment "UTF-8")
(setq slime-net-coding-system 'utf-8-unix)


(setq load-path (cons  "~/emacs" load-path))
(setq load-path (cons  "~/emacs/icicles" load-path))
(setq load-path (cons  "~/emacs/clojure" load-path))
(setq load-path (cons  "~/emacs/golang" load-path))
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
;;; Use "C-c %" to jump to the matching parenthesis.
(defun goto-match-paren (arg)
  "Go to the matching parenthesis if on parenthesis, otherwise insert
the character typed."
(interactive "p")
(cond ((looking-at "\\s\(") (forward-list 1) (backward-char 1))
      ((looking-at "\\s\)") (forward-char 1) (backward-list 1))
      (t                    (self-insert-command (or arg 1))) ))
(global-set-key (kbd "C-c %") `goto-match-paren)

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
 '(default ((t (:inherit nil :stipple nil :background "white" :foreground "black" :inverse-video nil :box nil :strike-through nil :overline nil :underline nil :slant normal :weight normal :height 122 :width normal :foundry "unknown" :family "Liberation Mono"))))
 '(my-long-line-face ((((class color)) (:background "gray80"))) t)
 '(my-tab-face ((((class color)) (:background "grey80"))) t)
 '(my-trailing-space-face ((((class color)) (:background "gray80"))) t))

;;(set-default-font "Terminus-12:bold")
(set-default-font "Inconsolata-14")
;;(set-default-font "Liberation Mono-12")

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
 ;; '(debug-on-error t)
 '(icicle-reminder-prompt-flag 4)
 '(menu-bar-mode t)
 '(save-place t nil (saveplace))
 '(show-paren-mode t)
 '(slime-backend "swank-loader.lisp"))


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
;; (require 'haxe-mode)
;; (defconst my-haxe-style
;;   '("java" (c-offsets-alist . ((case-label . +)
;;                                (arglist-intro . +)
;;                                (arglist-cont-nonempty . 0)
;;                                (arglist-close . 0)
;;                                (cpp-macro . 0))))
;;   "My haXe Programming Style")
;; (add-hook 'haxe-mode-hook
;;           (function (lambda () (c-add-style "haxe" my-haxe-style t))))
;; (add-hook 'haxe-mode-hook
;;           (function
;;            (lambda ()
;;              (setq tab-width 4)
;;              (setq indent-tabs-mode t)
;;              (setq fill-column 80)
;;              (local-set-key [(return)] 'newline-and-indent))))

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
(global-set-key (kbd "C-c l") 'literate-haskell-mode)

;; autopair stuff
(require 'autopair)
;;(autopair-global-mode)

;; golang stuff
(add-to-list 'load-path "PATH CONTAINING go-mode-load.el" t)
(require 'go-mode-load)

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

;; show functions stuff
(require 'show-functions)

(put 'downcase-region 'disabled nil)

(put 'upcase-region 'disabled nil)

;; shell stuff
(ansi-color-for-comint-mode-on)

;; anything.el
(require 'anything)

;; window switching
(defun select-next-window ()
  "Switch to the next window"
  (interactive)
  (select-window (next-window)))

(defun select-previous-window ()
  "Switch to the previous window"
  (interactive)
  (select-window (previous-window)))

(global-set-key (kbd "C-x o") 'select-next-window)
(global-set-key (kbd "C-x p")  'select-previous-window)


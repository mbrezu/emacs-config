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

;; tpl files are smarty templates so use html-mode
(setq auto-mode-alist (append '(("\\.tpl$" . html-mode))
                              auto-mode-alist))

;; django templates mode
(load "django-mode.el")

;; ;; gnuserv
;; (gnuserv-start)
;; (setq gnuserv-frame (selected-frame))

;; grep buffers
(load "grep-buffers.el")

;; ocaml mode
(setq auto-mode-alist (cons '("\\.ml\\w?" . tuareg-mode) auto-mode-alist))
(autoload 'tuareg-mode "tuareg" "Major mode for editing Caml code" t)
(autoload 'camldebug "camldebug" "Run the Caml debugger" t)

;; haskell mode
(load "~/emacs/haskell-mode-2.4/haskell-site-file")

(add-hook 'haskell-mode-hook 'turn-on-haskell-doc-mode)
(add-hook 'haskell-mode-hook 'turn-on-haskell-indent)
;;(add-hook 'haskell-mode-hook 'turn-on-haskell-simple-indent)

;; Clojure setup (including paredit)
(autoload 'clojure-mode "clojure-mode" "A major mode for Clojure" t)
(add-to-list 'auto-mode-alist '("\\.clj$" . clojure-mode))
;;(defun lisp-enable-paredit-hook () (paredit-mode 1))
;;(add-hook 'clojure-mode-hook 'lisp-enable-paredit-hook)

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

;; autopair stuff
(require 'autopair)
;;(autopair-global-mode)

;; golang stuff
(add-to-list 'load-path "PATH CONTAINING go-mode-load.el" t)
(require 'go-mode-load)

;; Window switching (this is unnecessary as I use something else for
;; windows switching).
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

;; Make new frames fullscreen by default. Note: this hook doesn't do
;; anything to the initial frame if it's in your .emacs, since that file is
;; read _after_ the initial frame is created.

(add-hook 'after-make-frame-functions 'toggle-fullscreen)

;; artbollocks
(require 'artbollocks-mode)
;; (add-hook 'text-mode-hook 'turn-on-artbollocks-mode)
;; (add-hook 'org-mode-hook 'turn-on-artbollocks-mode)

;; -*- mode: lisp; -*-
;; 2009-01-01 - legumbre

(in-package :stumpwm)

;;; looks
(setf *message-window-gravity* :center)
(setf *input-window-gravity* :bottom-left)

;; colors (two more reserved for the user)
(setf *colors*
      (append *colors* (list "dark slate gray" "crimson")))
(set-focus-color "dark slate gray")

;; volume control
;; (load "~/stumpwm/contrib/mamixer.lisp")
;; (load "~/stumpwm/contrib/battery.lisp")
;; (load "~/stumpwm/contrib/cpu.lisp")

;; Turn on mode line.
(setf *screen-mode-line-format*
      (list "%g"
	    '(:eval (make-string 120 :initial-element #\Space))
	    '(:eval (multiple-value-bind (second minute hour) (get-decoded-time) (format nil "~2,'0d:~2,'0d" hour minute)))))
(toggle-mode-line (current-screen) (current-head))

;;; commands

(defcommand urxvt () ()
  "Run or switch to urxvt term."
  (run-or-raise "/opt/local/bin/urxvt -e /usr/local/bin/bash --login" '(:class "URxvt")))
(define-key *root-map* (kbd "c") "urxvt")

(defcommand new-urxvt () ()
  "Create a new urxvt instance."
  (run-commands "exec /opt/local/bin/urxvt -e /usr/local/bin/bash --login"))
(define-key *root-map* (kbd "C-c") "new-urxvt")

(defcommand firefox () ()
  "Run or switch to firefox."
  (run-or-raise "firefox" '(:class "Firefox")))
(define-key *root-map* (kbd "f") "firefox")

(defcommand chrome () ()
  "Run or switch to Chrome."
  (run-or-raise "chromium" '(:class "Chrome")))
(define-key *root-map* (kbd "f") "chrome")

(defcommand conkeror () ()
  "Run or switch to Conkeror"
  (run-or-raise "/opt/local/bin/firefox-x11-devel-standalone  --app ~/conkeror/application.ini -repl" '(:role "browser")))
(define-key *root-map* (kbd "f") "conkeror")

(defcommand conkeror-unfocus () ()
  "unfocus conkeror"
  (run-commands "exec conkeror -f unfocus"))
(define-key *root-map* (kbd "u") "conkeror-unfocus")

(defcommand emacs-daemon () ()
  "Start emacs --daemon"
  (run-commands "exec emacs --daemon"))

(defcommand emacs () ()
  "Run or switch to emacs."
  (run-or-raise "urxvtc +ptab -bg black -fg wheat -fn \"xft:Droid Sans Mono:pixelsize=11\" -e /usr/bin/emacsclient -t" '(:title "emacsclient")))
(define-key *root-map* (kbd "E") "emacs")

(defcommand emacs-gtk () ()
  "Run or switch to gtk emacs."
  (run-or-raise "emacsclient -c --alternate-editor=\"\"" '(:class "Emacs")))
(define-key *root-map* (kbd "e") "emacs-gtk")

(defcommand hades () ()
  "Run or switch to root@hades."
  (run-or-raise "/opt/local/bin/urxvt -title hades -n hades -e ssh -i ~/.keys/leo.pem -C root@10.10.10.1" '(:title "hades")))
(define-key *root-map* (kbd "q") "hades")

(defcommand vnc-minileo () ()
  "Run or switch to vncviewer (VNC)"
  (run-or-raise "exec vncviewer minileo" '(:class "Vncviewer")))
(define-key *root-map* (kbd "m") "vnc-minileo")

(defcommand epdfview () ()
  "Run or switch to epdfview"
  (run-or-raise "exec epdfview" '(:class "Epdfview")))
(define-key *root-map* (kbd "C-o") "epdfview")

(defcommand bury-window () ()
  "Move the window to the end of the windows list."
  (renumber (+ 1 (apply 'max (mapcar 'window-number (group-windows (current-group))))))
  (echo-string (current-screen) (format nil "Buried window ~a: ~a" (window-name (current-window)) (window-number (current-window)))))
(define-key *root-map* (kbd "DEL") "bury-window")

;; screenshot command
(defvar *screenshot-timeout* 2)
(defvar *screenshot-output-dir* "/tmp")
(defcommand scrot () ()
  "Capture screenshot with external screenshot program."
  (let* ((filename 
          (multiple-value-bind (s m h d mo y) (get-decoded-time)
            (format nil "~4,'0d~2,'0d~2,'0d-~2,'0d~2,'0d~2,'0d" y mo d h m s)))
         (output-file (concat *screenshot-output-dir* "/" filename ".png"))
         (os (software-type)))
    (cond 
      ((equal os "Darwin") (run-commands (concat "exec screencapture -T 2" " " output-file)))
      ((equal os "Linux") (run-commands "exec scrot -d 2")))
    (message (format nil "saving screenshot as: ~a" output-file))))

;; suspend to disk 
(defcommand suspend () ()
  "Suspend to disk"
  (run-shell-command "echo disk > /sys/power/state"))

;; suspend to memory
(defcommand standby () ()
  "Suspend to disk"
  (run-shell-command "echo mem > /sys/power/state"))

(define-key *root-map* (kbd "RET") "gnext")
(define-key *root-map* (kbd "d") "echo-date")
(define-key *root-map* (kbd "I") "show-window-properties")


;; remember to put the right keycodes in .Xmodmap!
(define-keysym #x1008ff02 "XF86MonBrightnessUp")
(define-keysym #x1008ff03 "XF86MonBrightnessDown")

(defcommand increase-brightness () ()
  "Increase display brightness"
  (run-shell-command "echo $((`cat /sys/class/backlight/sony/brightness` + 1)) > /sys/class/backlight/sony/brightness"))
(define-key *top-map* (kbd "XF86MonBrightnessUp") "increase-brightness")

(defcommand decrease-brightness () ()
  "Decrease display brightness"
  (run-shell-command "echo $((`cat /sys/class/backlight/sony/brightness` - 1)) > /sys/class/backlight/sony/brightness"))
(define-key *top-map* (kbd "XF86MonBrightnessDown") "decrease-brightness")

;; Load swank.
(load "~/lisp/slime/swank.asd")
(asdf:operate 'asdf:load-op 'swank)

(defcommand swank () ()
  (setf stumpwm:*top-level-error-action* :break)
  (swank:create-server :port 4005
                       :style swank:*communication-style*
                       :dont-close t))

;; openvpn status
;;  (asdf:operate 'asdf:load-op 'usocket)
;;  (defun openvpn-query-state ()
;;    "Query openvpn state through TCP managament console"
;;    (let ((raw-socket (usocket:socket-connect "localhost" 7000)))
;;      (unwind-protect
;;           (let ((stream (usocket:socket-stream raw-socket)))
;;             (format stream "state~%")
;;             (force-output stream)
;;             (sleep 0.01)
;;             (loop
;;                (let ((line (read-line stream)))
;;                  (when
;;                      (or
;;                       (not (listen stream)) ;; nothing more to read
;;                       (and (not (search "END" line)) ;; line does not contain neither END nor INFO
;;                            (not (search "INFO" line))))
;;                    (return (second (split-string line ",")))))))
;;        (usocket:socket-close raw-socket))))


;; emacsish arrowless navigation for windows
(define-key *root-map* (kbd "C-n") "move-focus down")
(define-key *root-map* (kbd "C-p") "move-focus up")
(define-key *root-map* (kbd "C-f") "move-focus right")
(define-key *root-map* (kbd "C-b") "move-focus left")

(define-key *root-map* (kbd "C-n") "my-move-focus down")
(define-key *root-map* (kbd "C-p") "my-move-focus up")
(define-key *root-map* (kbd "C-f") "my-move-focus right")
(define-key *root-map* (kbd "C-b") "my-move-focus left")


;;; Startup commands

;; create groups and set up some windows
(echo-string (current-screen) "Starting swank.")
(run-commands "swank")
;; (run-commands "grename Main" "gnewbg .FS" "gnewbg .emacs") ;; hidden group .name syntax broke at some point
(run-commands "grename Main" "gnewbg FS" "gnewbg emacs")

;; rule based window placement
(clear-window-placement-rules)
(define-frame-preference "Main"
  ;; frame raise lock (lock AND raise == jumpto)
  (1 t t :class "URxvt"))
(define-frame-preference "emacs"
  (1 t t :class "Emacs")
  (0 nil nil :title "VLC"))

(define-frame-preference "FS"
  (1 t t :class "Firefox")
  (1 t t :class "Conkeror")
  (1 t t :class "Chrome")
  (1 t t :title "hades")
  (0 t t :class "Krdc")
  (1 t t :class "Quartus"))

(defcommand toggle-window-placement-rules () ()
  "Toggle window placement rules activation."
  (if (or (not (boundp '*window-placement-rules-disabled*))
          (not *window-placement-rules-disabled*))
      (setq *disabled-window-placement-rules* *window-placement-rules* 
            *window-placement-rules* nil
            *window-placement-rules-disabled* t)
      (setq *window-placement-rules* *disabled-window-placement-rules*
            *window-placement-rules-disabled* nil))
  (message "window placement rules ~a" 
           (if *window-placement-rules-disabled*
               "disabled"
               "enabled")))
(define-key *root-map* (kbd "C-r") "toggle-window-placement-rules")

;; xim input method for gtk (firefox)
;; (setf (getenv "GTK_IM_MODULE") "xim") ;;; problems with sbcl and setf env, c-string decode error

;; continue frame navigation over synergy displays
(defun my-move-focus-and-or-window (dir &optional win-p)
  (unless (move-focus-and-or-window dir win-p)
    (let ((f4-keycode (xlib:keysym->keycodes *display* 
                                             (keysym-name->keysym "F4")))
          (f5-keycode (xlib:keysym->keycodes *display* 
                                             (keysym-name->keysym "F5"))))
      (when (eq dir :left)
        (echo-string (current-screen) "Switching to left Synergy desktop.")
        (xtest:fake-key-event *display* f4-keycode t)
        (xtest:fake-key-event *display* f4-keycode nil))
      (when (eq dir :right)
        (echo-string (current-screen) "Switching to right Synergy desktop.")
        (xtest:fake-key-event *display* f5-keycode t)
        (xtest:fake-key-event *display* f5-keycode nil)))))

(defcommand (my-move-focus tile-group) (dir) ((:direction "Direction: "))
"Focus the frame adjacent to the current one in the specified
direction."
  (my-move-focus-and-or-window dir))


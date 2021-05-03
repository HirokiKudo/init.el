;;; Commentary:

;; My init.el.

;;; Code:

;;<leaf-install-code>
(eval-and-compile
  (customize-set-variable
   'package-archives '(
		       ("org" . "https://orgmode.org/elpa/")
                       ("melpa" . "https://melpa.org/packages/")
                       ("gnu" . "https://elpa.gnu.org/packages/")
		       )
   )
  (package-initialize)
  (unless (package-installed-p 'leaf)
    (package-refresh-contents)
    (package-install 'leaf)
    )

  (leaf leaf-keywords
    :ensure t
    :init
    ;; optional packages if you want to use :hydra, :el-get, :blackout,,,
    (leaf hydra :ensure t)
    (leaf el-get :ensure t)
    (leaf blackout :ensure t)

    :config
    ;; initialize leaf-keywords.el
    (leaf-keywords-init)
    )
  )
;; </leaf-install-code>

;; ここにいっぱい設定を書く
(leaf leaf
  :config
  (leaf leaf-convert :ensure t)
  (leaf leaf-tree
    :ensure t
    :custom (
	     (imenu-list-size . 30)
             (imenu-list-position . 'left)
	     )
    )
  )

(leaf macrostep
  :ensure t
  :bind (("C-c e" . macrostep-expand))
  )

;;https://mako-note.com/python-emacs-ide/を参考に追記
;;highlight-indent-guides
;;インデントの位置を強調表示するマイナーモード
(leaf highlight-indent-guides
  :ensure t
  :blackout t
  :hook (((prog-mode-hook yaml-mode-hook) . highlight-indent-guides-mode))
  :custom (
	   (highlight-indent-guides-method . 'character)
           (highlight-indent-guides-auto-enabled . t)
           (highlight-indent-guides-responsive . t)
           (highlight-indent-guides-character . ?|)
	   )
  )

;;white-space-modes
;;スペースやタブなどの空白を表示するマイナーモード
(leaf whitespace
  :ensure t
  :commands whitespace-mode
  :bind ("C-c W" . whitespace-cleanup)
  :custom (
	   (whitespace-style . '(face       ;faceで可視化
                                trailing    ;行末
                                tabs        ;タブ
                                spaces      ;スペース
                                empty       ;行頭/末尾の空行
                                space-mark  ;表示のマッピング
                                tab-mark)
			     )
           (whitespace-display-mappings . '(
					    (space-mark ?　 [?□])
                                            (tab-mark ?	 [?» ?	] [?\ ?	])
					    )
					)
	   ;;スペースは全角のみを可視化
           (whitespace-space-regexp . "\(　+\)")
           (whitespace-global-modes . '(emacs-lisp-mode shell-script-mode sh-mode python-mode org-mode))
           (global-whitespace-mode . t)
	   )
  :config
  (set-face-attribute 'whitespace-trailing nil
                      :background "Black"
                      :foreground "DeepPink"
                      :underline t)
  (set-face-attribute 'whitespace-tab nil
                      :background "Black"
                      :foreground "LightSkyBlue"
                      :underline t)
  (set-face-attribute 'whitespace-space nil
                      :background "Black"
                      :foreground "GreenYellow"
                      :weight 'bold)
    (set-face-attribute 'whitespace-empty nil
                      :background "Black")
  )

;;company-mode
;;Emacsの入力補完用のパッケージ
(leaf company
  :ensure t
  :leaf-defer nil
  :blackout company-mode
  :bind (
	 (company-active-map
          ("M-n" . nil)
          ("M-p" . nil)
          ("C-s" . company-filter-candidates)
          ("C-n" . company-select-next)
          ("C-p" . company-select-previous)
          ("C-i" . company-complete-selection)
	  )
         (company-search-map
          ("C-n" . company-select-next)
          ("C-p" . company-select-previous)
	  )
	 )
  :custom (
	   (company-tooltip-limit         . 12)
           (company-idle-delay            . 0) ;; 補完の遅延なし
           (company-minimum-prefix-length . 1) ;; 1文字から補完開始
           (company-transformers          . '(company-sort-by-occurrence))
           (global-company-mode           . t)
           (company-selection-wrap-around . t)
	   )
  )

;;Flycheck
;;構文チェッカー
;;FlycheckをElpyで利用するには、上記の設定に加え、elpy-modulesからelpy-module-flymakeを除く必要がありますので、その設定は後述のElpyの設定で行っています。
;;以下を拡張として導入
;;flycheck-inline: エラーをエコーエリアではなく、インライン内に表示
;;flycheck-color-mode-line: Flycheckのステータスをモードライン内にカラー表示
(leaf flycheck
  :ensure t
  :hook (prog-mode-hook . flycheck-mode)
  :custom ((flycheck-display-errors-delay . 0.3))
  :config
  (leaf flycheck-inline
    :ensure t
    :hook (flycheck-mode-hook . flycheck-inline-mode)
    )
  (leaf flycheck-color-mode-line
    :ensure t
    :hook (flycheck-mode-hook . flycheck-color-mode-line-mode)
    )
  )

;;Elpy
;;Emacs上にPython統合開発環境を提供するライブラリ
(leaf elpy
  :ensure t
  :init
  (elpy-enable)
  :config
  (remove-hook 'elpy-modules 'elpy-module-highlight-indentation) ;; インデントハイライトの無効化
  (remove-hook 'elpy-modules 'elpy-module-flymake) ;; flymakeの無効化
  :custom
  (elpy-rpc-python-command . "python3") ;; https://mako-note.com/elpy-rpc-python-version/の問題を回避するための設定
  (flycheck-python-flake8-executable . "flake8")
  :bind (elpy-mode-map
         ("C-c C-r f" . elpy-format-code)
	 )
  :hook ((elpy-mode-hook . flycheck-mode))
  )

;;Flymakeの無効化
(remove-hook 'elpy-modules 'elpy-module-flymake)

;;Elpyのインデントハイライトの無効化
;;最初に設定したhighlight-indent-guidesのほうが私は見やすいので、Elpyのインデントハイライトを以下の設定で無効化しています。
(remove-hook 'elpy-modules 'elpy-module-highlight-indentation)

(provide 'init)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(macrostep leaf-tree leaf-convert leaf-keywords hydra el-get blackout)
   )
 )
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
)
 ;; Local Variables:
;; indent-tabs-mode: nil
;; End:

;;; init.el ends here

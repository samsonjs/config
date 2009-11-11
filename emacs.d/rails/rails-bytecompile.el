(require 'rails)

(mapcar
 #'byte-compile-file
 (directory-files "./" t "^[a-z]\\.el$"))
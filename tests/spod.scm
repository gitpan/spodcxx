;#+ bigloo
(module spod
	(export
	  	; Parsing, makes SPOD structure
	  	(spod:parse input-file . comment)
		; Formatting
		(spod:to-text pod . args)
		(spod:to-html pod . args)
		(spod:to-rtf pod . args)
		(spod:to-spod pod var file)
		(spod:standard-CSS)
		(spod:format-html POD tabsize linelen contents)
		(spod:format-rtf pod tabsize linelen)
		; Links
		(spod:parse-link str)
		(spod:link-description link)
		(spod:link link)
		; Version
		(spod:version)
		(spod:license)
		; Generic Format Helpers
		(spod:parse-format-codes handler str)
		(spod:process-formats handler POD)
		; Handling the SPOD structure
		(spod:pod-get-keyword POD key)
		(spod:pod-headers POD)
		(spod:pod-get-title POD)
		; Handling the SPOD data structure
		(spod:pod-mk key val)
		(spod:pod-eq? entry key)
		(spod:pod-context entry)
		(spod:pod-context! entry context)
		(spod:pod-text entry)
		(spod:pod-text! entry text)
		(spod:pod-val entry)
		(spod:pod-val! entry val)
		(spod:pod-opt entry)
		(spod:pod-opt! entry opt)
		(spod:pod-key entry)
		(spod:pod-key! entry key)
		(spod:pod-entry key . args)
		(spod:pod-merge entry1 entry2)
		; Handling 'over' situations
		(spod:newlevel level over)
		; Parsing arguments
		(spod:get-args handler args)))
;#+ gauche
;(define-module spod
;	(export 
;	  	; Parsing, makes SPOD structure
;	  	spod:parse
;		; Formatting
;		spod:to-text
;		spod:to-html
;		spod:to-rtf
;		spod:to-spod
;		spod:standard-CSS
;		spod:format-html
;		spod:format-rtf
;		; Links
;		spod:parse-link
;		spod:link-description
;		spod:link
;		; Version
;		spod:version
;		spod:license
;		; Generic Format helpers
;		spod:parse-format-codes	
;		spod:process-formats
;		; Handling the SPOD structure
;		spod:pod-get-keyword
;		spod:pod-headers
;		spod:pod-get-title
;		; Handling the SPOD data structure
;		spod:pod-mk
;		spod:pod-eq?
;		spod:pod-context
;		spod:pod-context!
;		spod:pod-text
;		spod:pod-text!
;		spod:pod-val
;		spod:pod-val!
;		spod:pod-opt
;		spod:pod-opt!
;		spod:pod-key
;		spod:pod-key!
;		spod:pod-entry
;		spod:pod-merge
;		; Handling 'over' situations
;		spod:newlevel
;		; Parsing arguments
;		spod:get-args
;	))
;(select-module spod)
;##

;--------------------------------------------------------------------------
; pod for scheme  $Id: spod.scm,v 1.2 2004/09/15 07:18:58 cvs Exp $
; PLEASE NOTE: THIS FILE HAS TABSIZE 4!
;--------------------------------------------------------------------------

;--------------------------------------------------------------------------
;=pod
;=head1 Name
;
;Scheme SPOD - A POD implementation for Scheme
;
;=head1 Version
;
;@VERSION 0.9@
;
;=head1 Author
;
;Hans Oesterholt <hdnews@gawab.com>
;
;=head1 Compatibility
;
;This POD implementation has been tested with the following scheme
;variants.
;
;=over 0
;=item * bigloo
;=item * gauche
;=back
;
;=head1 SYNOPSYS
;
; gosh> (define POD (spod:parse "test.scm"))
; POD
;
; gosh>(spod:to-spod POD "test.pod")
; #t
;
; gosh>(spod:to-text POD)
; (-; A lot of	tabbed	text displayed... ;-)
; (-; Yes,	tabbed		text ;-)
; #t
;
; gosh>(spod:to-text POD "test.txt")
; #t
;
; gosh>(spod:to-text POD)
; #t
;
; gosh>(spod:to-html POD)
; (-; A lot of html displayed... ;-)
; #t
;
; gosh>(spod:to-html POD "test.html")
; #t
;
;=head1 DESCRIPTION
;
;This is a plain old documentation implementation for Gauche Scheme.
;This simple though powerfull documentation language facilitates documenting
;perl scripts. So why should it not facilitate documenting scheme?
;
;You can look at the perlpod manual page for a description of the POD language.
;
;=head1 TODO
;
;=over 0
;
;=item 1. 
;
;Need to implement linking features (L<..>).
;
;=item 1. 
;
;Need to add support for different style sheets in HTML and add a default style
;setup, if none is provided.
;
;=item 1. 
;
;The escape recursion function (text-to-tree) doesn't do a good job on
;CE<lt>EE<lt>ltE<gt>bla blaEE<lt>gtE<gt>E<gt>. The last closing E<gt>
;won't be parsed, C<E<lt>as can be seenE<gt>>, you see? NO? Please 
;C<E<lt>look againE<gt>>. AHA, IT'S in the ITEM HANDLING!!! See below!
;
;=back
;
;C<I'm I<confused! italics>>
;
;C<I'm really B<confused! bold>>
;
;C<I'm really badly confused! boldE<gt>>
;
;=head1 C<really really B<confused>>
;
;=over 1
;=item C<hmm? B<hmm?>>
;
;=item C<hmmmm? I<hmmm hmm>>
;
;=item C<hmmmm? I<hmmm hmm>> kep.
;
;=back
;
;
;
;=cut
;--------------------------------------------------------------------------

;--------------------------------------------------------------------------
;=head1 FUNCTIONS
;=head2 (spod:version)
;=over 1
;This function returns the version string of this scheme module.
;=back
;=cut
;--------------------------------------------------------------------------

(define (spod:version)
  	(string-append "v" (VERSION)))

(define (spod:license)
  	(define (concat l)
	  	(if (eq? l '())
		  	(string #\newline)
			(string-append (string #\newline) (car l) (concat (cdr l)))))
	(concat (LICENSE)))

(define (VERSION)
  	(define (subst v s)
	  	(if (eq? s '())
		  	v
			(subst (string-subst v (car s) "") (cdr s))))
	(subst "@VERSION 0.9@" '("@" " " "VERSION")))

(define (LICENSE)
  		(list 
		  	(string-append "SPOD - Scheme Plain Old Documentation, version " (VERSION))
	  		"(c) 2004 Hans Oesterholt-Dijkema <hdnews@gawab.com>" ""
	  		"License: LGPL, see www.gnu.org for details." ""))

;--------------------------------------------------------------------------
;=head2 (spod:parse-with-comment file comment)
;Internally used by C<(spod:parse file . comment)>.
;=cut
;--------------------------------------------------------------------------

(define (spod:parse-with-comment file comment) 
	;----------------------------------------------------------------------
	; Getting line info/processing lines
	;----------------------------------------------------------------------

	(define (empty-line? line comment)
		(let ((l (trim line)))
			(if (string=? l comment)
				#t
				(= (string-length l) 0))))
				
	(define (comment-line? line comment)
	  	(let ((nc (string-length comment)))
		  	(let* ((l (trim line))
				   (n (string-length l)))
			  	(if (>= n nc)
				  	(string=? (substring l 0 nc) comment)
					#f))))

	; This function will trim-left the line until it finds the
	; last left-like comment. Only if (> (string-length comment) 0)
	; so: comment whitespace comment comment whitespace comment should
	; be perfectly acceptable.
	(define (canonize-comment line comment)
	  	(let ((nc (string-length comment)))
	  		(define (f line pos index)
		  		(if (>= (string-length line) nc)
				  	(if (ws? (substring line 0 1))
					  	(f (substring line 1 (string-length line)) pos (+ index 1))
						(if (string=? (substring line 0 nc) comment)
						  	(f (substring line nc (string-length line)) index (+ index nc))
							pos))
					pos))
			(if (string=? comment "")
			  	line
				(substring line (f line 0 0) (string-length line)))))

	; precondition: (and (comment-line? line comment) (canonize-comment line comment))
	(define (is-verbatim? line comment)
	  	(let* ((nc (string-length comment))
			   (n (string-length line)))
		  	(if (> n nc)
			  	(ws? (substring line nc (+ nc 1)))
				#f)))

	;----------------------------------------------------------------------
	; Trying keywords
	;----------------------------------------------------------------------
	
	;precondition: (canonize-comment line comment)
	(define (keyeq? line key)
	  	(let ((nc (string-length comment)))
			(if (>= (string-length line) (+ nc (string-length key)))
				(string-ci=? (substring line nc (+ nc (string-length key))) key)
				#f)))
	
	(define (pod? line)
		(keyeq? line "=pod"))
		
	(define (cut? line)
		(keyeq? line "=cut"))
		
	(define (over? line)
		(keyeq? line "=over"))
	
	(define (back? line)
		(keyeq? line "=back"))
		
	(define (item? line)
		(keyeq? line "=item"))
		
	;precondition: (canonize-comment line comment)
	(define (head? line)
		(if (keyeq? line "=head")
		  	(let* ((nc (string-length comment))
				   (hl (string-length "=head"))
				   (n  (substring line (+ nc hl) (+ nc hl 1))))
			  	(if (and (string>=? n "1") (string<=? n "9"))
				  	(string->number n)
					0))
			0))
	
	(define (head1? line)
		(eq? (head? line) 1))
	
	(define (head2? line)
		(eq? (head? line) 2))
		
	(define (head3? line)
		(eq? (head? line) 3))
	
	(define (head4? line)
		(eq? (head? line) 4))
		
	(define (head5? line)
		(eq? (head? line) 5))
	
	; Get and trim line, don't use for verbatim parts!
	(define (get-line line key)
	  	(let* ((l (remove-comment line comment))
			   (n (string-length l))
			   (nk (string-length key)))
		  	(if (>= nk n)
			  	""
				(trim (substring l (+ nk 1) n)))))
		
	(define (verbatim? line)
		(if (empty-line? line comment)	; empty Comment or empty line
			#f
			(if (comment-line? line comment)
			  	(is-verbatim? line comment)
				#f)))
				
	(define (alinea? line)
		(if (empty-line? line comment)
			#f
			(if (comment-line? line comment)
				(not (is-verbatim? line comment))
				#f)))

	(define (begin? line)
		(keyeq? line "=begin"))

	(define (end? line)
		(keyeq? line "=end"))

	(define (for? line)
		(keyeq? line "=for"))

	;----------------------------------------------------------------------
	; Getting the right parts of the scentense	
	;----------------------------------------------------------------------
	
	(define (gethead line)
	  	(spod:pod-entry "HEAD" (get-line line "head0") (head? line)))
		
	(define (gethead1 line current)
		(gethead line))
		
	(define (gethead2 line current)
		(gethead line))
		
	(define (gethead3 line current)
		(gethead line))
	
	(define (gethead4 line current)
		(gethead line))
	
	(define (gethead5 line current)
		(gethead line))
	
	(define (getverb line current)
		(if (eq? current '())
			(spod:pod-entry "VERBATIM" (string-append (remove-comment line comment) (string #\newline)))
			(spod:pod-entry "VERBATIM" (string-append (cadr current) (remove-comment line comment) (string #\newline)))))
	
	(define (getverbatim line current)
		(getverb line current))
	
	(define (getalinea line current)
		(if (eq? current '())
			(spod:pod-entry "ALINEA" (string-append (remove-comment line comment) (string #\newline)))
			(spod:pod-entry "ALINEA" (string-append (cadr current) (remove-comment line comment) (string #\newline)))))
			
	(define (getover line current)	;=over
		(let ((n (string->number (get-line line "=over"))))
			(spod:pod-entry "OVER" (if (eq? n #f) -1 n))))
		
	(define (getback line current)	;=back
		(spod:pod-entry "BACK"))
		
	(define (getitem line current)	;=item
	  	(define (get-type line)
		  	(let ((w (get-first-word line)))
			  	(cond
				  	((in w '("-")) "dash")
					((in w '("*" "+" "#" "%")) "bullet")
					((eq? (string->number w) #f) "word")
					(else "number"))))
		(spod:pod-entry "ITEM" (get-line line "=item") (get-type (get-line line "=item"))))

	(define (getbegin line current)	;=begin
		(spod:pod-entry "FORMAT-BEGIN" (get-first-word (get-line line "=begin"))))

	(define (getend line current) ;=end
		(spod:pod-entry "FORMAT-END" (get-first-word (get-line line "=end"))))

	(define (getformat line current) ;=for
		(spod:pod-entry "FORMAT" (get-first-word (get-line line "=for"))))

	; AND DEFINE -- LITERAL
			
	;----------------------------------------------------------------------
	; Parsing a scheme source to a list of SPOD keys
	;----------------------------------------------------------------------
	
	(define (parse-pod-seq port)
		(let (	(ready #f)
				(inpod #f)
				(status "none")
				(prevstatus "")
				(pod '())
				(current '())
				(level 0)
				(scope '())
			 )
			(do () ((eq? ready #t) pod)
				(let ((line (read-line port))) 
					(if (eof-object? line)
						(set! ready #t)
						(begin
							(if (not (string=? comment ""))
								(set! line (canonize-comment (trim line) comment)))
							
							(set! prevstatus status)

							(cond 
								((pod? line) 		(set! status "pod"))
								((cut? line) 		(set! status "cut"))
								((head1? line)		(set! status "head1"))
								((head2? line)  	(set! status "head2"))
								((head3? line)  	(set! status "head3"))
								((head4? line)  	(set! status "head4"))
								((head5? line)  	(set! status "head5"))
								((over? line) 		(set! status "over"))
								((back? line) 		(set! status "back"))
								((item? line)		(set! status "item"))
								((begin? line)		(set! status "begin"))
								((end? line)		(set! status "end"))
								((for? line)		(set! status "format"))
								; These are generic, don't put keywords under them!
								((verbatim? line) 	(set! status "verbatim"))
								((alinea? line) 	(set! status "alinea"))
								(else 				(set! status "none")))

							(if (not (string=? prevstatus status))
								(begin
									(if (and (not (eq? current '())) (eq? inpod #t))
										(begin
											(set! pod (append pod (list current)))
											(set! current '())))
								))
								
							(cond 
								((or (string=? status "head1")
									 (string=? status "head2")
									 (string=? status "head3")
									 (string=? status "head4")
									 (string=? status "head5")
									 (string=? status "begin"))
										 (set! inpod #t)))
									
							(if (eq? inpod #t)
								(cond 
									((string=? status "verbatim") 
										(set! current (getverb line current)))
									((string=? status "alinea")
										(set! current (getalinea line current)))
									((string=? status "head1")
										(set! current (gethead1 line current)))
									((string=? status "head2")
										(set! current (gethead2 line current)))
									((string=? status "head3")
										(set! current (gethead2 line current)))
									((string=? status "head4")
										(set! current (gethead2 line current)))
									((string=? status "head5")
										(set! current (gethead2 line current)))
									((string=? status "over")
										(set! current (getover line current)))
									((string=? status "back")
										(set! current (getback line current)))
									((string=? status "item")
										(set! current (getitem line current)))
									((string=? status "cut")
										(set! inpod #f))
									((string=? status "begin")
										(set! current (getbegin line current)))
									((string=? status "end")
										(set! current (getend line current)))
									((string=? status "format")
										(set! current (getformat line current))))
								(cond 
									((string=? status "pod")
										(set! inpod #t))))
							
							(if (>= (string-length status) 4)
								(cond
									((string=? (substring status 0 4) "head")
										(set! status "reset"))
									((in status '("over" "back" "begin" "end" "item"))
										(set! status "reset"))))))))))

	(define (parse-pod port)
		(parse-pod-seq port))


	;----------------------------------------------------------------------
	; Formatting functions
	;----------------------------------------------------------------------

	(define (do-escapes handler str)
	  	(spod:parse-format-codes handler str))

	(define (do-format-alinea handler str)
		str)

	(define (merge-any pod any)
		(define (is-any? pod any )
			(if (eq? pod '())
				#f
				(spod:pod-eq? (car pod) any)))
		(if (eq? pod '())
			'()
			(if (is-any? pod any)
			(if (is-any? (cdr pod) any)
				(merge-any (cons (spod:pod-merge (car pod) (cadr pod)) (cddr pod)) any)
				(cons (car pod) (merge-any (cdr pod) any)))
			(cons (car pod) (merge-any (cdr pod) any)))))
			
	(define (merge-verbatims pod)
		(merge-any pod "VERBATIM"))

	;----------------------------------------------------------------------
	; making the spod list structure
	;----------------------------------------------------------------------

	(define (make file) 
		(let
;#+ gauche
;		     ((input (open-input-file file :if-does-not-exist #f)))
;#+ bigloo
		     ((input (open-input-file file)))
;##
		  	(if (eq? input #f)
				#f
				(merge-verbatims (parse-pod input)))))
			
	;----------------------------------------------------------------------
	; main part
	;----------------------------------------------------------------------
	
	(make file))


;--------------------------------------------------------------------------
; spod:parse
;--------------------------------------------------------------------------
;
;=head2 (spod:parse file . comment-delimiter)
;
;This function takes a file and an optional comment-delimiter.
;If no comment is given, the default comment-delimiter ";" is taken.
;It parses the file to the SPOD data structure. If comment-delimiter
;is the empty string (""), files are parsed as if they were '.pod'
;files. This will e.g. work with the C<C> language, when using /* */
;comments and pod language on empty lines. E.g.:
;
; /*
; =head1 Name
; This is a C module.
; =cut
; */
;
;It won't work for C++ comments like 'E<sol> E<sol>'. If you're using C++ comments
;like 'E<sol>E<sol>', you'll have to specify a comment-delimiter 'E<sol>E<sol>. 
;Example:
;
; //=head1 Name
; //This is a C++ module.
; //=cut
;
;=cut

(define (spod:parse file . comment)
  	(if (eq? comment '())
		(spod:parse-with-comment file ";")
		(spod:parse-with-comment file (car comment))))

;--------------------------------------------------------------------------
; spod:to-text
;--------------------------------------------------------------------------

;----------------------------------------------------------------------
; writing out the SPOD structure using text markup
;----------------------------------------------------------------------

(define (format-text POD tabsize linelength)
	(define (handle-format format entry)
		'())
	(define (do-pod2text POD)
	  	(define (get-text entry)
		  	(define (format-code-handler cmd s)
			  	(define (cvt-esc c)
				  	(lookup c (list '("lb" "\n") '("lt" "<") '("gt" ">") '("sol" "/") '("verbar" "|"))))
			  	(cond
				  	((string=? cmd "E") (cvt-esc s))
					(else s)))
		  	(spod:parse-format-codes format-code-handler (spod:pod-text entry)))
		(define (nl r)
			(string-append r (string #\newline)))
		(define (mt r l s)
			(nl (string-append r (indent l s))))
		(define (alinea s level linelen)
			(let* ((S (string-append (string-subst s (string #\newline) " ") " "))
				   (N (string-length S))
				   (k 0)
				   (lastspace 0)
				   (L (- linelen (indent-size level)))
				   (r ""))
				(do ((i 0 (+ i 1)))
					((>= i N) r)
						(begin
							(if (> k L)
								(begin
									(set! k 0)
									(set! r (nl r))
									(set! lastspace (+ lastspace 1))))
							(if (char=? (string-ref S i) #\space)
								(begin
									(set! r (string-append r (substring S lastspace i)))
									(set! lastspace i)))
							(set! k (+ k 1))))))
		(define (literal r level s)
			(string-append r s))
		(let ((level 0)
			  (levelstack '())
			  (retval ""))
			(do () 
				((eq? POD '()) retval)
					(let ((key (spod:pod-key (car POD))))
						(begin 
							(cond 
								((string=? key "HEAD")
									(begin
										(set! level (- (spod:pod-opt (car POD)) 1))
										(set! retval (nl (mt retval level (get-text (car POD)))))
										(set! level (spod:pod-opt (car POD)))))
								((string=? key "OVER")
									(begin
										(set! levelstack (cons level levelstack))
										(set! level (spod:newlevel level (spod:pod-val (car POD))))))
								((string=? key "BACK")
									(begin
										(if (eq? levelstack '())
											(set! level 0)
											(begin 
												(set! level (car levelstack))
												(set! levelstack (cdr levelstack))))))
								((string=? key "ITEM")
									(begin
										(set! level (- level 1))
										(set! retval (mt retval level (get-text (car POD))))
										(set! level (+ level 1))
										(if (not (eq? (cdr POD) '()))
											(if (spod:pod-eq? (cadr POD) "BACK")
												(set! retval (nl retval))))))
								((string=? key "VERBATIM")
									(begin
										(set! retval 
											(mt retval (+ level 1) (process-tabs (spod:pod-text (car POD)) tabsize)))))
								((string=? key "ALINEA")
									(begin
										(set! retval 
											(nl (mt retval level (alinea (get-text (car POD)) level linelength))))))
								((string=? key "LITERAL")
									(set! retval (literal retval level (spod:pod-text (car POD)))))
								(else 
									(begin
										(set! retval (mt retval level (get-text (car POD)))))))
							(set! POD (cdr POD)))))))
	(do-pod2text (spod:process-formats handle-format POD)))

;--------------------------------------------------------------------------
;=pod
;=head2 (spod:to-text <SPOD> . <filename>)
;=over 1
;Takes a previously made SPOD closure by (spod:make <filename>)
;and outputs it using text markup to standard output or, if given,
;the given filename.
;=back
;=cut
;--------------------------------------------------------------------------

(define (spod:to-text pod . args) 
  	(let ((tabsize 8)
		  (linelength 75)
	  	  (file ""))
	  	(define (set-arg key value)
		  	(define (to-num val)
			  	(if (number? val) val (string->number val)))
			(cond 
				((string-ci=? key "file")    (set! file value))
				((string-ci=? key "tab")     (set! tabsize (to-num value)))
				((string-ci=? key "linelen") (set! linelength (to-num value)))
				(else (if (string=? key "") (set! file value)))))
		(begin
	  		(spod:get-args set-arg args)
			(let ((txt (format-text pod tabsize linelength)))
				(if (string=? file "")
					(begin
						(display txt)
						#t)
					(let ((p (open-output-file file)))
						(display txt p)
						(close-output-port p)
						#t))))))
	
;--------------------------------------------------------------------------
; spod:to-spod
;--------------------------------------------------------------------------

;----------------------------------------------------------------------
; writing out the SPOD structure to a file
;----------------------------------------------------------------------

(define (to-spod POD var file)
	(define (p2p p l)
		(if (not (list? l))
			(begin 
				(display " " p)
				(write l p))
			(if (not (eq? l '()))
				(if (list? l)
					(begin 
						(display "(list " p)
						(map (lambda (x) (p2p p x)) l)
						(display ")\n" p))))))
	(let ((p (open-output-file file)))
		(begin
			(display "(define " p)
			(display var p)
			(display " " p)
			(p2p p POD)
			(display ")" p)
			(display (string #\newline) p)
			(close-output-port p)
			#t)))
	
		
;--------------------------------------------------------------------------
;=pod
;=head2 (spod:to-spod <SPOD> <variable-name> <filename>)
;=over 1
;Takes a previously made SPOD closure and outputs it as 
;a scheme define to the given filename.
;The scheme define gets the variable name of E<lt>variable-nameE<gt>.
;E<lt>variable-nameE<gt> is a string.
;
;=head3 example:
;	gosh> (define POD (spod:make "spod.scm"))
;	POD
;	gosh> (spod:to-spod POD "podstruct" "spod.pod")
;	#t
;=back
;=cut
;--------------------------------------------------------------------------

(define (spod:to-spod pod var file)
  	(begin
	  	(to-spod pod var file)
		#t))

;--------------------------------------------------------------------------
; spod:to-html
;--------------------------------------------------------------------------

;----------------------------------------------------------------------
; writing out the SPOD structure using HTML markup
;----------------------------------------------------------------------

(define (spod:format-html POD tabsize linelen contents)

  	; HMTL Tags
	(define (bold s)
		(string-append "<B>" s "</B>"))
	(define (italics s)
		(string-append "<I>" s "</I>"))
	(define (small s)
		(string-append "<SMALL>" s "</SMALL>"))
	(define (tiny s)
		(string-append "<DIV class=tiny>" s "</DIV>"))
	(define (center s)
		(string-append "<CENTER>" s "</CENTER>"))

	; HTML Conversion
	(define (html-cvt s)
		(define (cvt s l)
			(if (eq? l '())
				s
				(cvt (string-subst s (caar l) (cadar l)) (cdr l))))
		(cvt s '(("&" "&amp;") ("<" "&lt;") (">" "&gt;") ("\"" "&quot;"))))

	; Special format strings (=for, =begin, =end) stuff
	(define (handle-formats format entry)
	  	(cond 
		  	((string-ci=? format "html")
			 	(spod:pod-mk "LITERAL" (spod:pod-val entry)))
			((string-ci=? format "title")
			 	(spod:pod-mk "TITLE" (spod:pod-val entry)))
			(else 
			  	'())))

	; Handler for format codes
	(define (html-handler cmd s)
	  	(define (cvt-esc s)
			(let ((c (lookup s 
					 	(list 	
						  	'("lb"	   "<br>")
				  			'("lt"     "&lt;")
							'("gt"     "&gt;")
							'("sol"    "/")
							'("verbar" "|")
							'("lchevron" "&laquo;")
							'("lverbar"  "&raquo;")))))
			  	(if (eq? c #f)
				  	(string-append "&" s ";")
					c)))

		(cond 
		  	((string=? cmd "PRE") (html-cvt s))
			((string=? cmd "POST") s)
			((string=? cmd "C") (string-append "<CODE>" s "</CODE>"))
			((string=? cmd "B") (string-append "<B>" s "</B>"))
			((string=? cmd "I") (string-append "<I>" s "</I>"))
			((string=? cmd "F") (string-append "<I>" s "</I>"))
			((string=? cmd "X") (string-append "<A NAME=\"" s "\"></A>"))
			((string=? cmd "Z") (string-append "<!--" s "-->"))
			((string=? cmd "L") (let ((L (spod:parse-link s)))
								  	(string-append "<A HREF=" 
												   		(spod:link L) 
													">" 
													(spod:link-description L) 
													"</A>")))
			((string=? cmd "S") (string-append (string-subst s " " "&#160")))
			((string=? cmd "E") (cvt-esc s))
			(else s)))

	; Caller for format codes handler (spod:parse-format-codes)
	(define (post-process s)
			(spod:parse-format-codes html-handler s))

	; Indenting code
	(define (start-indent level r)
		(let ((l (if (> level 7) 7 level)))
			(string-append r "<DIV class=indent" (number->string l) ">\n")))
	(define (end-indent level r)
		(string-append r "</DIV>\n"))

	; Construct a reference (<A NAME=, <A HREF=), etc.
	(define (mk-name s)
		(let ((r "")
			  (n (string-length s)))
			(do ((i 0 (+ i 1)))
				((>= i n) (string-subst (trim r) " " "_"))
					(let ((c (string-ref s i)))
						(if (or (and (char>=? c #\0) (char<=? c #\9))
								(and (char-ci>=? c #\a) (char-ci<=? c #\z)))
							(set! r (string-append r (string c)))
							(set! r (string-append r " ")))))))

	; HTML Referencing
	(define (ref s)
		(string-append "<A NAME=\"" (mk-name s) "\">"))
	(define (local-link s)
		(string-append "<A HREF=\"#" (mk-name s) "\">"))
	(define (end-ref) "</A>")
	(define (end-link) "</A>")

	; Table of contents construction 
	(define (toc contents POD maxlevel)
		(define (toc-indent level r)
			(let ((l (if (> level 7) 7 level)))
				(string-append r "<DIV class=indent" (number->string l) ">\n")))
		(define (end-toc-indent level r)
			(string-append r "</DIV>\n"))
		(define (mk-hdr hdr)
			(let ((level (spod:pod-opt hdr))
				  (s     (spod:pod-text hdr)))
				(if (<= level maxlevel)
					(string-append 
						(local-link s) 
						(toc-indent level "")
						(post-process s)
						(end-toc-indent level "")
						(end-link))
					"")))
		(define (mk-toc HDRS)
			(if (eq? HDRS '())
				""
				(string-append (mk-hdr (car HDRS)) (mk-toc (cdr HDRS)))))
		(string-append 
			"<DIV class=toc>"
			"<A NAME=\"_top\"><H1>" contents "</H1></A>"
			(mk-toc (spod:pod-headers POD))
			"</DIV>"))

	; The Internal function to construct HTML from the SPOD Internal Structure
	(define (do-to-html POD tabsize linelen)
	  	; Make a HTML header
		(define (head r n s)
			(string-append 
				r 
				"<DIV class=header>"
				(ref s) (end-ref) 
				(local-link "_top") 
				"<H" (number->string n) ">" (post-process s) "</H" (number->string n) ">"
				(end-link)
				"</DIV>"
				"\n"))

		; Make an HTML item
		(define (item itemtype r s level)
			(if (string=? itemtype "word")
				(string-append r
					"<DIV class=itemindent><DIV class=itemcolor>"
					(post-process s)
					"</DIV></DIV>\n")
				(string-append r "<LI>" (post-process (drop-first-word s)) "\n")))

		; Start an item sequence 
		(define (start-items type r)
			(if (string=? type "number")
				(string-append r "<OL>\n")
				(if (or (string=? type "word") (string=? type "none"))
					r
					(string-append r "<UL>\n"))))

		; End item sequence
		(define (end-items type r)
			(if (string=? type "number")
				(string-append r "</OL>\n")
				(if (or (string=? type "word") (string=? type "none"))
					r
					(string-append r "</UL>\n"))))

		; Try to get the type of items
		(define (get-item-type pod)
			(if (eq? pod '())
				"none"
				(if (spod:pod-eq? (car pod) "ITEM")
				  	(spod:pod-opt (car pod))
					"none")))

		; Verbose text
		(define (verb r s tabsize)
			(string-append r "<PRE>" (html-cvt (process-tabs s tabsize)) "</PRE>\n"))

		; Alinea text
		(define (alinea r level s)
			(string-append r "<P>" (post-process s) "</P>\n"))

		; Copy through, put in literal, no post processing 
		(define (literal r level s)
			(string-append r s))

		; Anything else 
		(define (default r level s)
			(string-append r (post-process s)))

		; OK, begin constructing the HTML now
		(let ((level 0)
			  (levelstack '())
			  (retval "")
			  (itemtype "none")
			  (itemtypestack '()))
			(do () 
				((eq? POD '()) retval)
					(let ((key (spod:pod-key (car POD))))
						(begin 
							(cond 
								((string=? key "HEAD")
									(begin
										(set! retval (head retval (spod:pod-opt (car POD)) (spod:pod-text (car POD))))))
								((string=? key "OVER")
									(begin
										(set! levelstack (cons level levelstack))
										(set! level (spod:newlevel level (spod:pod-val (car POD))))
										(set! itemtypestack (cons itemtype itemtypestack))
										(set! itemtype (get-item-type (cdr POD)))
										(set! retval (start-indent level retval))
										(set! retval (start-items itemtype retval))))
								((string=? key "BACK")
									(begin
										(if (eq? levelstack '())
											(set! level 0)
											(begin 
												(set! retval (end-items itemtype retval))
												(set! retval (end-indent level retval))
												(set! level (car levelstack))
												(set! levelstack (cdr levelstack))
												(set! itemtype (car itemtypestack))
												(set! itemtypestack (cdr itemtypestack))))))
								((string=? key "ITEM")
									(begin
										(set! retval (item itemtype retval (spod:pod-text (car POD)) level))))
								((string=? key "VERBATIM")
									(begin
										(set! retval (verb retval (spod:pod-text (car POD)) tabsize))))
								((string=? key "ALINEA")
									(begin
										(set! retval (alinea retval level (spod:pod-text (car POD))))))
								((string=? key "LITERAL")
									(begin
										(set! retval (literal retval level (spod:pod-text (car POD))))))
								((string=? key "TITLE")
								 	(begin 
									  	(set! retval retval)))
								(else 
									(begin
										(set! retval (default retval level (spod:pod-text (car POD)))))))
							(set! POD (cdr POD)))))))
	(string-append 
	  	(if (eq? contents #f) "" (toc contents POD 2))
		"<DIV class=text>"
		(do-to-html (spod:process-formats handle-formats POD) tabsize linelen)
		"</DIV>"))
	

;--------------------------------------------------------------------------
;=pod
;=head2 (spod:to-html <SPOD> . <filename>)
;=over 1
;Takes a previously made SPOD closure by (spod:make <filename>)
;and outputs it using HTML markup to standard output or, if given,
;the given filename.
;=head3 example:
;	gosh> (load "./spod.scm")
;	#t
;	gosh> (define POD (spod:make "spod.scm" 4))
;	POD
;	gosh> (spod:to-html POD "spod.html")
;	#t
;	gosh> 
;=back
;=cut
;--------------------------------------------------------------------------

						
(define (spod:to-html pod . args)
  	(let ((file "")
		  (stylesheet "")
		  (tab 8)
		  (linelen 75)
		  (contents "Contents"))

	  	; parse arguments
	  	(define (set-arg key value)
		  	(cond 
			  	((string-ci=? key "file") (set! file value))
				((string-ci=? key "stylesheet") (set! stylesheet value))
				((string-ci=? key "tab")  (set! tab  (if (number? value) value (string->number value))))
				((string-ci=? key "contents") (set! contents value))
				(else (if (string=? key "") (set! file value)))))

		; Construct the HTML body
		(define (html body POD)

			; Convert version
			(define (version)
	  			(define (v l)
		  			(if (eq? l '())
			  			""
			  			(string-append "<!-- " (car l) " -->\n" (v (cdr l)))))
				(v (LICENSE)))

			(string-append 
				"<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\">\n"
				"<HTML><HEAD>\n"
				(version)
				"<META http-equiv=\"Content-Type\" content=\"text/html; charset=iso-8859-1\">\n"
				(if (string=? stylesheet "")
				  	(string-append 
					  	"<STYLE TYPE=\"text/css\">\n"
						"<!--\n"
						(spod:standard-CSS)
						"-->\n"
						"</STYLE>\n")
					(string-append 
						"<LINK rel=\"stylesheet\" href=\"" 
						stylesheet 
						"\" type=\"text/css\">\n"))
				"<TITLE>" (spod:pod-get-title POD) "</TITLE>\n"
				"</HEAD>\n"
				"<BODY>\n"
				"<DIV class=spod>\n"
				body
				"<br><p>"
				"\n<!-- generated by spod:to-html " (VERSION) "-->\n"
				"</DIV>\n"
				"</BODY></HTML>\n"))

		(begin
		  	(spod:get-args set-arg args)
			(let ((output (html (spod:format-html pod tab linelen contents) pod)))
			  	(if (string=? file "")
				  	(begin 
					  	(display output)
						#t)
					(let ((p (open-output-file file)))
						(display output p)
						(close-output-port p)
						#t))))))

;=head2 to-rtf

(define (spod:to-rtf pod . args)
  #f
  )

(define (spod:format-rtf pod tabsize linelen)
  #f
  )

;--------------------------------------------------------------------------
; Documentation about internals
;--------------------------------------------------------------------------
;=pod
;=head1 Writing your own pod formatter
;
;----------------------------------------------------------------------
;=head1 Providing functions for handling the internal datastructure
;
;Internal structure: ((key . context) text . optional)
;See documentation below.
;=head2 Handling the internal POD structure
;=cut
;----------------------------------------------------------------------

(define (spod:pod-mk key val)
  	(list (list key) val))

(define (spod:pod-eq? entry key)
  	(string-ci=? (caar entry) key))

(define (spod:pod-context entry)
  	(if (eq? (cdar entry) '())
	  	""
		(cadar entry)))

(define (spod:pod-context! entry context)
  	(cons (list (caar entry) context) (cdr entry)))

(define (spod:pod-text entry)
  	(if (eq? (cdr entry) '())
	  	""
		(cadr entry)))

(define (spod:pod-val entry) 
  	(spod:pod-text entry))

(define (spod:pod-text! entry text)
  	(cons (car entry) (cons text (cddr entry))))

(define (spod:pod-val! entry val)
  	(spod:pod-text! entry val))

(define (spod:pod-opt entry)
  	(if (eq? (cddr entry) '())
	  	#f
		(caddr entry)))

(define (spod:pod-opt! entry opt)
  	(cons (car entry) (cons (cadr entry) (list opt))))

(define (spod:pod-key entry)
  	(caar entry))

(define (spod:pod-key! entry key)
  	(cons (cons key (cdar entry)) (cdr entry)))

(define (spod:pod-entry key . args)
  	(cons (list key) args))

(define (spod:pod-merge v1 v2)
  	(spod:pod-text! v1 (string-append (spod:pod-text v1) "\n" (spod:pod-text v2))))

  
(define (spod:newlevel level over)
	(if (< over 0)
		(+ level 1)
		(+ level over)))

;----------------------------------------------------------------------
;=head1 Parsing link structures
;=head2 (spod:parse-link str)
;precondition: str is the contents of a C<LE<lt>...E<gt>> sequence, i.e. C<L<E<lt>strE<gt>>>.
;postcondition: = a list of 6 entries, that have following meaning:
;
;=over 1
;
;=item car 
;
;Contains the link text.
;
;=item cadr
;
;Contains the possibly inferred link text.
;
;=item caddr
;
;Contains the name of the link, e.g. a http link.
;
;=item cadddr
;
;Contains the section of a link (like the # modifier in a http link).
;
;=item caddddr
;
;Contains the type of the link, e.g. 'pod', 'man', 'url'.
;
;=item cadddddr
;
;Contains the original B<str> variable.
;
;=head3 algorithm
;
;- First: Lookup the first pipe symbol. The text before
;  the pipe is the link description.
;  The text after the pipe is the link.
;
;=cut
;----------------------------------------------------------------------

(define (spod:parse-link str)
  	(define (pipe-pos str)
	  	(do ((i 0 (+ i 1))
			 (n (string-length str))
			 (found #f))
		  	((or (>= i n) found) (if (= i n) #f i))
			(set! found (char=? (string-ref str i) #\|))))
	(let* ((pipe (pipe-pos str))
		   (descr (trim (if (eq? pipe #f) str (substring str 0 (- pipe 1)))))
		   (link  (trim (if (eq? pipe #f) str (substring str pipe (string-length str))))))
		(if (pregexp-match "^\\w+:[^:\\s]\\S*$" link)
			(list descr link link "" "url" str)
			(list descr link link "" "?" str))))

(define (spod:link link)
  	(cadr link))

(define (spod:link-description link)
  	(car link))
			
;----------------------------------------------------------------------
;=head2 Parsing and Processing Format Codes
;Parse and process format codes in an alinea or line provided in str,
;using a handler provided by the formatter.
;=cut
;----------------------------------------------------------------------

(define (spod:parse-format-codes handler str)
	;------------------------------------------------------------------
	; The difficult section to parse Formatting Codes from text
	;------------------------------------------------------------------

	(define (text-to-tree txt)
	
		; Find out if this is the start of a Format Code
		(define (is-esc-open? str)
	
			(define (simple-open str)
				(if (>= (string-length str) 2)
					(and (char=? (string-ref str 1) #\<) (char-upper-case? (string-ref str 0)))
					#f))
	
			(define (hairy-open str)
				(define (f1 str n)
					(if (= (string-length str) 0)
						#f
						(if (char=? (string-ref str 0) #\<)
							(f1 (substring str 1 (string-length str)) (+ n 1))
							(if (char-whitespace? (string-ref str 0))
								n
								#f))))
				(if (>= (string-length str) 3)
					(if (and (simple-open str) (char=? (string-ref str 2) #\<))
						(f1 (substring str 3 (string-length str)) 2)
						(if (simple-open str) 
							1
							#f))
					(simple-open str)))
		
			(hairy-open str))
	
		; Make an escape code
		(define (get-esc str i esc)
			(list "ESC" (substring str i (+ i 1)) esc))
	
		; Split a string in escape codes
		(define (esc-split str)
			(let ((n (string-length str))
				  (i 0)
				  (result '())
				  (k 0))
				(do ((esc (is-esc-open? str) (is-esc-open? (substring str i n))))
					((>= i n) (append result (list (list "STR" (substring str k n)))))
						(if (eq? esc #f)
							(set! i (+ i 1))
							(begin 
								(set! result
									(append result (list (list "STR" (substring str k i)) (get-esc str i esc))))
								(set! i (+ i (+ esc 1)))
								(set! k i))))))
	
		; This function finds a closer for a format code
		; It takes the number of opening tags ('<') as input (see podspec)
		(define (find-closer tags str)
			(define (simple str k)
				(let ((n (string-length str))
					  (pos #f))
					(do ((i k (+ i 1)))
						((or (not (eq? pos #f)) (>= i n)) pos)
							(if (char=? (string-ref str i) #\>)
								(set! pos i)))))
	
			(define (hairy tags str)
				(let ((n (string-length str)))
					(define (right-tag str i tags)
	
						(define (f str II i n tags)
							(if (<= tags 0)
								II
								(if (>= i n)
									#f
									(if (char=? (string-ref str i) #\>)
										(f str II (+ i 1) n (- tags 1))
										#f))))
	
						(if (= i 0)
							#f
							(if (char-whitespace? (string-ref str (- i 1)))
								(f str i i n tags)
								#f)))
	
					(do ((i (simple str 0) (simple str (+ i 1))))
						((or (eq? i #f) (right-tag str i tags)) i))))
	
			(if (= tags 1)
				(simple str 0)
				(hairy tags str)))
	
		(define (tt l)
			(let ((stack '()))
	
			; We need a level stack to get this list into a tree
			(define (spush r)
				(set! stack (cons r stack)))
	
			(define (spop)
				(if (eq? stack '())
					#f
					(let ((r (car stack)))
						(set! stack (cdr stack))
						r)))
	
			; What's the number of opening tags on the stack?
			(define (get-close-n)
				(if (eq? stack '())
					0
					(caddar stack)))
	
			; Is this the starting of an Format Code?
			(define (open? r)
				(string=? (car r) "ESC"))
	
			; Can we find a closer with the current number of closing tags?
			(define (close? r)
				(find-closer (get-close-n) r))
	
			; We found a closer, now get the right string results
			(define (get-close str)
				(let ((i (close? str))
					(n (string-length str)))
					(list (list "STR" (substring str 0 i)) 
						(list "CLOSE")
						(list "STR" (substring str (+ i (get-close-n)) n)))))
						
			(define (f level)
				
				(define (f2 level i)
					(if (eq? l '())
						'()
						(begin 
							(if (> i 0) (spush (car l)))
							(set! l (cdr l))
							(let ((result (f (+ level  i))))
								(if (> i 0) (spop))
								(list result)))))
				(define (f3 level)
					(begin
						(set! l (cdr l))
						(f level)))
				
				(if (eq? l '())
					'()
					(cond
						((open? (car l))
							(cons (cons (car l) (f2 level 1)) (f level)))
						((close? (cadar l))
							(let ((r (get-close (cadar l))))
								(set! l (cons (caddr r) (cdr l)))
								(list (car r))))
						(else (cons (car l) (f3 level))))))
			(f 0)))
	
			(define (remove-ws tree)
				(if (eq? tree '())
					'()
					(if (list? (caar tree))
						(cons (remove-ws (car tree)) (remove-ws (cdr tree)))
						(if (string=? (caar tree) "STR")
							(if (= (string-length (trim (cadar tree))) 0)
								(cons '("STR" "") (remove-ws (cdr tree)))
								(cons (car tree) (remove-ws (cdr tree))))
							(cons (car tree) (remove-ws (cdr tree)))))))
			
		;(remove-ws (tt (esc-split txt))))
		(tt (esc-split txt)))

	; The actual spod:parse-format-codes

	(let ((tree (text-to-tree str)))

	  	(define (process tree cmd)
		  	(if (eq? tree '())
			  	'()
				(if (list? (car tree))
				  	(cons (process (car tree) cmd) (process (cdr tree) cmd))
					(if (string=? (car tree) "STR")
					  	(list "STR" (handler cmd (cadr tree)))	; deepest level = '(cmd value)
						tree))))

	  	(define (process-esc tree)
		  	(define (f tree cmd)
			  	(if (eq? tree '())
				  	""
					(if (list? (caar tree))
					  	(string-append (f (car tree) cmd) (f (cdr tree) cmd))	; tree gets deeper
						(if (string=? (caar tree) "ESC")
						  	(handler (cadar tree) (f (cdr tree) (cadar tree)))	; handle ESCape
							(string-append (cadar tree) (f (cdr tree) cmd))))))	; let rest bubble up

			(f tree "NONE"))

		(handler "POST" (process-esc (process tree "PRE")))))

;----------------------------------------------------------------------
;=head2 process format blocks 
;Process C<=begin E<lt>formatE<gt>>, =end E<lt>formatE<gt> 
;and =for E<lt>formatE<gt> alineas
;=cut
;----------------------------------------------------------------------

(define (spod:process-formats handler pod)

	(define (pskips pod)
		(if (eq? pod '())
			'()
			(if (eq? (car pod) '())
				(pskips (cdr pod))
				(cons (car pod) (pskips (cdr pod))))))

	(define (pf pod)
	  	(let ((formstack '(#f))
			  (once #f))

		  	(define (push format)
			  	(set! formstack (cons format formstack)))
			(define (pop)
			  	(if (not (eq? (car formstack) #f))
				  	(set! formstack (cdr formstack))))
			(define (format)
			  	(car formstack))

		  	(define (f entry)
			  	(let ((key (spod:pod-key entry)))
				  	(cond 
					  	((string=? key "FORMAT-BEGIN")
						 	(begin
							  	(push (spod:pod-val entry))
								'()))
						((string=? key "FORMAT-END")
						 	(begin
							  	(pop)
								'()))
						((string=? key "FORMAT")
						 	(begin
							  	(push (spod:pod-val entry))
								(set! once #t)
								'()))
						(else
						 	(let ((form (format)))
						  		(if (eq? once #t)
								  	(begin
								  		(set! once #f)
										(pop)
										(handler form entry))
									(if (eq? form #f)
								  		entry
										(handler form entry))))))))
			(map f pod)))

	(pskips (pf pod)))

;----------------------------------------------------------------------
;=head2 Getting various things from SPOD list
;=cut
;----------------------------------------------------------------------

(define (spod:pod-get-keyword pod key)
	(if (eq? pod '())
		'()
		(if (spod:pod-eq? (car pod) key)
			(cons (car pod) (spod:pod-get-keyword (cdr pod) key))
			(spod:pod-get-keyword (cdr pod) key))))
					
(define (spod:pod-headers pod)
	(spod:pod-get-keyword pod "HEAD"))

(define (spod:pod-get-title pod)

  	(define (is-title entry)
	  	(and (or (spod:pod-eq? entry "FORMAT-BEGIN") (spod:pod-eq? entry "FORMAT"))
			 (string-ci=? (spod:pod-val entry) "TITLE")))

	(define (is-name entry)
		(if (spod:pod-eq? entry "HEAD")
			(string-ci=? (trim (spod:pod-text entry)) "NAME")
			#f))

	(define (get-next-line pod)
		(if (eq? pod '())
			#f
			(if (spod:pod-eq? (car pod) "ALINEA")
				(one-line (spod:pod-text (car pod)))
				(get-next-line (cdr pod)))))

	(define (get-title pod)
		(if (eq? pod '())
			#f
			(if (is-title (car pod))
			  	(get-next-line (cdr pod))
				(if (is-name (car pod))
					(get-next-line (cdr pod))
					(get-title (cdr pod))))))

	(define (get-title-from-first-header pod)
	  	(let ((headers (spod:pod-headers pod)))
		  	(if (eq? headers '())
			  	"no title"
				(spod:pod-text (car headers)))))

	(let ((title (get-title pod)))
	  	(if (eq? title #f)
		  	(get-title-from-first-header pod)
			title)))

;----------------------------------------------------------------------
;=head1 Module Internal Supporting functions
;Generic string functions
;=cut
;----------------------------------------------------------------------

(define (ws? s)
	(or (string=? s " ") (string=? s (string #\tab))))
		
(define (wsc? c)
	(or (char=? c #\space) (char=? c #\tab)))
		
(define (trim-left line)
	(if (< (string-length line) 1) 
		line
		(if (ws? (substring line 0 1))
		  	(trim-left (substring line 1 (string-length line)))
			line)))
							 
(define (trim-right line)
	(let ((n  (string-length line)))
		 (let ((pn (- n 1)))
			(if (< n 1)
				line
				(let ((r (substring line pn n)))
					(if (ws? r)
						(trim-right (substring line 0 pn))
						line))))))
	
(define (trim line)
	(trim-left (trim-right line)))
	
(define (extcur line f cur)
	(append cur (f line)))
	
(define (in s l)
	(if (eq? l '())
		#f
		(if (string=? s (car l))
			#t
			(in s (cdr l)))))

(define (lookup s l)
  	(if (eq? l '())
	  	#f
		(if (string=? (caar l) s)
			  	(cadar l)
				(lookup s (cdr l)))))

;----------------------------------------------------------------------
;=head2 various string and line functions
;Functions for string searching, subsituting, 
;indenting, tabbing, removing comments, 
;getting first words
;=cut
;----------------------------------------------------------------------
	
	(define (strstr-from from s1 s2)
		(define (srch s1 s2 i n2 mi)
			(if (<= i mi)
				(if (string=? (substring s1 i (+ i n2)) s2)
					i
					(srch s1 s2 (+ i 1) n2 mi))
				#f))
		(let ((n1 (string-length s1))
			  (n2 (string-length s2)))
			(if (> n2 n1) 
				#f
				(srch s1 s2 from n2 (- n1 n2)))))

	(define (strstr s1 s2)
		(strstr-from 0 s1 s2))
	
	(define (string-subst s1 s2 s3)
		(let ((s s1)
			  (r "")
			  (n (string-length s2)))
			(do ((i (strstr s1 s2)))
				((eq? i #f) (string-append r s))
					(begin
						(set! r (string-append r (substring s 0 i) s3))
						(set! s (substring s (+ i n) (string-length s)))
						(set! i (strstr s s2))))))

	(define (drop k s)
		(let ((n (string-length s)))
			(if (>= k n)
				""
				(substring s k n))))
	
	(define (indent-size level)
		(* 2 level))
		
	(define (indent l s)
		(define (mkindent l)
			(if (> l 1) 
				(string-append "  " (mkindent (- l 1)))
				""))
		(let ((ind (mkindent l)))
			(string-append 
				ind 
				(string-subst s 
					(string #\newline) 
					(string-append (string #\newline) ind)))))
					
	(define (process-tabs s ts)
		(let* ((r "")
			   (n (string-length s))
			   (tab "\t")
			   (k 0))
			(do ((i 0 (+ i 1))) 
				((>= i n) r)
					(begin 
						(if (char=? (string-ref s i) #\tab)
							(let ((m (- ts (modulo k ts))))
								(set! r (string-append r (make-string m #\space)))
								(set! k (+ k m)))
							(if (char=? (string-ref s i) #\newline)
								(begin
									(set! r (string-append r (string (string-ref s i))))
									(set! k 0))
								(begin
									(set! r (string-append r (string (string-ref s i))))
									(set! k (+ k 1)))))))))
						
	(define (remove-comment line comment)
	  	(let ((nc (string-length comment)))
		  	(if (= nc 0)
			  	line
				(let* ((l (trim line))
					   (n (string-length l)))
				  	(if (>= n nc)
					  	(if (string=? (substring l 0 nc) comment)
						  	(substring l nc n)
							line))))))
						
	(define (get-first-word line)
		(let ((l (trim line))
			  (r "")
			  (n (string-length line)))
			(do ((i 0 (+ i 1)))
				((or (>= i n) (wsc? (string-ref l i))) (substring l 0 i)))))

	(define (drop-first-word line)
		(trim-left (drop (string-length (get-first-word line)) line)))

	(define (one-line s)
		(let ((i (strstr s "\n")))
			(if (eq? i #f)
				s
				(substring s 0 i))))

;
;=head2 (spod:get-args handler args)
;
;Processing argument lists
;process argument lists like '("key" value) or "key=value"
;
;=cut
;
(define (spod:get-args handler args)
  	(define (f arg)
		(handler (car arg) (cadr arg)))
  	(define (proc-arg arg)
	  	(let ((r '()))
			(if (list? arg)
		  		arg
				(do ((n (string-length arg)) (i 0 (+ i 1)))
			  		((or (>= i n) (char=? (string-ref arg i) #\=)) 
					 	(if (>= i n)
						  	(if (char=? (string-ref arg 0) #\-)
							  	(list arg "")
								(list "" arg))
							(list (substring arg 0 i) (substring arg (+ i 1) n))))))))
	(if (not (eq? args '()))
	  	(begin
	  		(f (proc-arg (car args)))
			(spod:get-args handler (cdr args)))))


;--------------------------------------------------------------------------
; Internal CSS support (for HTML)
;--------------------------------------------------------------------------

(define (spod:standard-CSS)
  	(string-append 
		"/* " (string #\newline)
		"   $Id: spod.scm,v 1.2 2004/09/15 07:18:58 cvs Exp $" (string #\newline)
		"" (string #\newline)
		"   Why invent the weel again?" (string #\newline)
		"" (string #\newline)
		"   This style sheet originates from cpan.org and has been extended" (string #\newline)
		"   with various indent levels and has modified colours." (string #\newline)
		"*/" (string #\newline)
		"" (string #\newline)
		"BODY {" (string #\newline)
		"  background: white;" (string #\newline)
		"  color: black;" (string #\newline)
		"  font-family: arial,sans-serif;" (string #\newline)
		"  margin: 0;" (string #\newline)
		"  padding: 1ex;" (string #\newline)
		"}" (string #\newline)
		"" (string #\newline)
		"TABLE {" (string #\newline)
		"  border-collapse: collapse;" (string #\newline)
		"  border-spacing: 0;" (string #\newline)
		"  border-width: 0;" (string #\newline)
		"  color: inherit;" (string #\newline)
		"}" (string #\newline)
		"" (string #\newline)
		"IMG { border: 0; }" (string #\newline)
		"FORM { margin: 0; }" (string #\newline)
		"input { margin: 2px; }" (string #\newline)
		"" (string #\newline)
		"A.fred {" (string #\newline)
		"  text-decoration: none;" (string #\newline)
		"}" (string #\newline)
		"" (string #\newline)
		"A:link, A:visited {" (string #\newline)
		"  background: transparent;" (string #\newline)
		"  color: #008855;" (string #\newline)
		"}" (string #\newline)
		"" (string #\newline)
		"A[href=\"#POD_ERRORS\"] {" (string #\newline)
		"  background: transparent;" (string #\newline)
		"  color: #FF0000;" (string #\newline)
		"}" (string #\newline)
		"" (string #\newline)
		"TD {" (string #\newline)
		"  margin: 0;" (string #\newline)
		"  padding: 0;" (string #\newline)
		"}" (string #\newline)
		"" (string #\newline)
		"DIV {" (string #\newline)
		"  border-width: 0;" (string #\newline)
		"}" (string #\newline)
		"" (string #\newline)
		"DT {" (string #\newline)
		"  margin-top: 1em;" (string #\newline)
		"}" (string #\newline)
		"" (string #\newline)
		".credits TD {" (string #\newline)
		"  padding: 0.5ex 2ex;" (string #\newline)
		"}" (string #\newline)
		"" (string #\newline)
		".huge {" (string #\newline)
		"  font-size: 32pt;" (string #\newline)
		"}" (string #\newline)
		"" (string #\newline)
		".s {" (string #\newline)
		"  background: #dddddd;" (string #\newline)
		"  color: inherit;" (string #\newline)
		"}" (string #\newline)
		"" (string #\newline)
		".s TD, .r TD {" (string #\newline)
		"  padding: 0.2ex 1ex;" (string #\newline)
		"  vertical-align: baseline;" (string #\newline)
		"}" (string #\newline)
		"" (string #\newline)
		"TH {" (string #\newline)
		"  background: #bbbbbb;" (string #\newline)
		"  color: inherit;" (string #\newline)
		"  padding: 0.4ex 1ex;" (string #\newline)
		"  text-align: left;" (string #\newline)
		"}" (string #\newline)
		"" (string #\newline)
		"TH A:link, TH A:visited {" (string #\newline)
		"  background: transparent;" (string #\newline)
		"  color: black;" (string #\newline)
		"}" (string #\newline)
		"" (string #\newline)
		".box {" (string #\newline)
		"  border: 1px solid #006699;" (string #\newline)
		"  margin: 1ex 0;" (string #\newline)
		"  padding: 0;" (string #\newline)
		"}" (string #\newline)
		"" (string #\newline)
		".distfiles TD {" (string #\newline)
		"  padding: 0 2ex 0 0;" (string #\newline)
		"  vertical-align: baseline;" (string #\newline)
		"}" (string #\newline)
		"" (string #\newline)
		".manifest TD {" (string #\newline)
		"  padding: 0 1ex;" (string #\newline)
		"  vertical-align: top;" (string #\newline)
		"}" (string #\newline)
		"" (string #\newline)
		".l1 {" (string #\newline)
		"  font-weight: bold;" (string #\newline)
		"}" (string #\newline)
		"" (string #\newline)
		".l2 {" (string #\newline)
		"  font-weight: normal;" (string #\newline)
		"}" (string #\newline)
		"" (string #\newline)
		".t1, .t2, .t3, .t4  {" (string #\newline)
		"  background: #006699;" (string #\newline)
		"  color: white;" (string #\newline)
		"}" (string #\newline)
		".t4 {" (string #\newline)
		"  padding: 0.2ex 0.4ex;" (string #\newline)
		"}" (string #\newline)
		".t1, .t2, .t3  {" (string #\newline)
		"  padding: 0.5ex 1ex;" (string #\newline)
		"}" (string #\newline)
		"" (string #\newline)
		"/* IE does not support  .box>.t1  Grrr */" (string #\newline)
		".box .t1, .box .t2, .box .t3 {" (string #\newline)
		"  margin: 0;" (string #\newline)
		"}" (string #\newline)
		"" (string #\newline)
		".t1 {" (string #\newline)
		"  font-size: 1.4em;" (string #\newline)
		"  font-weight: bold;" (string #\newline)
		"  text-align: center;" (string #\newline)
		"}" (string #\newline)
		"" (string #\newline)
		".t2 {" (string #\newline)
		"  font-size: 1.0em;" (string #\newline)
		"  font-weight: bold;" (string #\newline)
		"  text-align: left;" (string #\newline)
		"}" (string #\newline)
		"" (string #\newline)
		".t3 {" (string #\newline)
		"  font-size: 1.0em;" (string #\newline)
		"  font-weight: normal;" (string #\newline)
		"  text-align: left;" (string #\newline)
		"}" (string #\newline)
		"" (string #\newline)
		"/* width: 100%; border: 0.1px solid #FFFFFF; */ /* NN4 hack */" (string #\newline)
		"" (string #\newline)
		".datecell {" (string #\newline)
		"  text-align: center;" (string #\newline)
		"  width: 17em;" (string #\newline)
		"}" (string #\newline)
		"" (string #\newline)
		".cell {" (string #\newline)
		"  padding: 0.2ex 1ex;" (string #\newline)
		"  text-align: left;" (string #\newline)
		"}" (string #\newline)
		"" (string #\newline)
		".label {" (string #\newline)
		"  background: #aaaaaa;" (string #\newline)
		"  color: black;" (string #\newline)
		"  font-weight: bold;" (string #\newline)
		"  padding: 0.2ex 1ex;" (string #\newline)
		"  text-align: right;" (string #\newline)
		"  white-space: nowrap;" (string #\newline)
		"  vertical-align: baseline;" (string #\newline)
		"}" (string #\newline)
		"" (string #\newline)
		".categories {" (string #\newline)
		"  border-bottom: 3px double #006699;" (string #\newline)
		"  margin-bottom: 1ex;" (string #\newline)
		"  padding-bottom: 1ex;" (string #\newline)
		"}" (string #\newline)
		"" (string #\newline)
		".categories TABLE {" (string #\newline)
		"  margin: auto;" (string #\newline)
		"}" (string #\newline)
		"" (string #\newline)
		".categories TD {" (string #\newline)
		"  padding: 0.5ex 1ex;" (string #\newline)
		"  vertical-align: baseline;" (string #\newline)
		"}" (string #\newline)
		"" (string #\newline)
		".path A {" (string #\newline)
		"  background: transparent;" (string #\newline)
		"  color: #006699;" (string #\newline)
		"  font-weight: bold;" (string #\newline)
		"}" (string #\newline)
		"" (string #\newline)
		".pages {" (string #\newline)
		"  background: #dddddd;" (string #\newline)
		"  color: #006699;" (string #\newline)
		"  padding: 0.2ex 0.4ex;" (string #\newline)
		"}" (string #\newline)
		"" (string #\newline)
		".path {" (string #\newline)
		"  background: #dddddd;" (string #\newline)
		"  border-bottom: 1px solid #006699;" (string #\newline)
		"  color: #006699;" (string #\newline)
		" /*  font-size: 1.4em;*/" (string #\newline)
		"  margin: 1ex 0;" (string #\newline)
		"  padding: 0.5ex 1ex;" (string #\newline)
		"}" (string #\newline)
		"" (string #\newline)
		".menubar TD {" (string #\newline)
		"  background: #006699;" (string #\newline)
		"  color: white;" (string #\newline)
		"}" (string #\newline)
		"" (string #\newline)
		".menubar {" (string #\newline)
		"  background: #006699;" (string #\newline)
		"  color: white;" (string #\newline)
		"  margin: 1ex 0;" (string #\newline)
		"  padding: 1px;" (string #\newline)
		"}" (string #\newline)
		"" (string #\newline)
		".menubar .links     {" (string #\newline)
		"  background: transparent;" (string #\newline)
		"  color: white;" (string #\newline)
		"  padding: 0.2ex;" (string #\newline)
		"  text-align: left;" (string #\newline)
		"}" (string #\newline)
		"" (string #\newline)
		".menubar .searchbar {" (string #\newline)
		"  background: black;" (string #\newline)
		"  color: black;" (string #\newline)
		"  margin: 0px;" (string #\newline)
		"  padding: 2px;" (string #\newline)
		"  text-align: right;" (string #\newline)
		"}" (string #\newline)
		"" (string #\newline)
		"A.m:link, A.m:visited {" (string #\newline)
		"  background: #006699;" (string #\newline)
		"  color: white;" (string #\newline)
		"  font: bold 10pt Arial,Helvetica,sans-serif;" (string #\newline)
		"text-decoration: none;" (string #\newline)
		"}" (string #\newline)
		"" (string #\newline)
		"A.o:link, A.o:visited {" (string #\newline)
		"  background: #006699;" (string #\newline)
		"  color: #ccffcc;" (string #\newline)
		"  font: bold 10pt Arial,Helvetica,sans-serif;" (string #\newline)
		"text-decoration: none;" (string #\newline)
		"}" (string #\newline)
		"" (string #\newline)
		"A.o:hover {" (string #\newline)
		"  background: transparent;" (string #\newline)
		"  color: #ff6600;" (string #\newline)
		"  text-decoration: underline;" (string #\newline)
		"}" (string #\newline)
		"" (string #\newline)
		"A.m:hover {" (string #\newline)
		"  background: transparent;" (string #\newline)
		"  color: #ff6600;" (string #\newline)
		"  text-decoration: underline;" (string #\newline)
		"}" (string #\newline)
		"" (string #\newline)
		"table.dlsip     {" (string #\newline)
		"  background: #dddddd;" (string #\newline)
		"  border: 0.4ex solid #dddddd;" (string #\newline)
		"}" (string #\newline)
		"" (string #\newline)
		".spod {" (string #\newline)
		"  background: white;" (string #\newline)
		"  color: black;" (string #\newline)
		"  font-family: arial,sans-serif;" (string #\newline)
		"  margin: 0;" (string #\newline)
		"  padding: 1ex;" (string #\newline)
		"}" (string #\newline)
		"" (string #\newline)
		".spod PRE     {" (string #\newline)
		"  background: #eeeeee;" (string #\newline)
		"  border: 1px solid #888888;" (string #\newline)
		"  color: black;" (string #\newline)
		"  padding: 1em;" (string #\newline)
		"  white-space: pre;" (string #\newline)
		"}" (string #\newline)
		"" (string #\newline)
		".spod H1      {" (string #\newline)
		"  background: transparent;" (string #\newline)
		"  color: #008866;" (string #\newline)
		"  font-size: large;" (string #\newline)
		"}" (string #\newline)
		"" (string #\newline)
		".spod H2      {" (string #\newline)
		"  background: transparent;" (string #\newline)
		"  color: #008866;" (string #\newline)
		"  font-size: medium;" (string #\newline)
		"}" (string #\newline)
		"" (string #\newline)
		".spod H3	{" (string #\newline)
		"  background: transparent;" (string #\newline)
		"  color: #000000;" (string #\newline)
		"  font-size: normal;" (string #\newline)
		"}" (string #\newline)
		"" (string #\newline)
		"" (string #\newline)
		".spod .itemindent {" (string #\newline)
		"	margin-left: -1em;" (string #\newline)
		"   margin-bottom: -0.5em;" (string #\newline)
		"}" (string #\newline)
		".spod .itemcolor {" (string #\newline)
		"	color: #205555;" (string #\newline)
		"}" (string #\newline)
		"" (string #\newline)
		".spod .indent1 {" (string #\newline)
		"	margin-left: 1em;" (string #\newline)
		"}" (string #\newline)
		"" (string #\newline)
		".spod .indent2 {" (string #\newline)
		"	margin-left: 2em;" (string #\newline)
		"}" (string #\newline)
		"" (string #\newline)
		".spod .indent3 {" (string #\newline)
		"	margin-left: 3em;" (string #\newline)
		"}" (string #\newline)
		"" (string #\newline)
		".spod .indent4 {" (string #\newline)
		"	margin-left: 4em;" (string #\newline)
		"}" (string #\newline)
		"" (string #\newline)
		".spod .indent5 {" (string #\newline)
		"	margin-left: 5em;" (string #\newline)
		"}" (string #\newline)
		"" (string #\newline)
		".spod .indent6 {" (string #\newline)
		"	margin-left: 6em;" (string #\newline)
		"}" (string #\newline)
		"" (string #\newline)
		".spod .indent7 {" (string #\newline)
		"	margin-left: 7em;" (string #\newline)
		"}" (string #\newline)
		"" (string #\newline)
		".spod IMG     {" (string #\newline)
		"  vertical-align: top;" (string #\newline)
		"}" (string #\newline)
		"" (string #\newline)
		".spod .header {" (string #\newline)
		"  text-decoration: none;" (string #\newline)
		"}" (string #\newline)
		"" (string #\newline)
		".spod .text {" (string #\newline)
		"  text-decoration: none;" (string #\newline)
		"}" (string #\newline)
		"" (string #\newline)
		".spod .text PRE     {" (string #\newline)
		"  background: #eeeeee;" (string #\newline)
		"  border: 1px solid #888888;" (string #\newline)
		"  color: black;" (string #\newline)
		"  padding: 1em;" (string #\newline)
		"  white-space: pre;" (string #\newline)
		"}" (string #\newline)
		"" (string #\newline)
		".spod .text H1      {" (string #\newline)
		"  background: transparent;" (string #\newline)
		"  color: #008866;" (string #\newline)
		"  font-size: large;" (string #\newline)
		"}" (string #\newline)
		"" (string #\newline)
		".spod .text H2      {" (string #\newline)
		"  background: transparent;" (string #\newline)
		"  color: #008866;" (string #\newline)
		"  font-size: medium;" (string #\newline)
		"}" (string #\newline)
		"" (string #\newline)
		".spod .text H3	{" (string #\newline)
		"  background: transparent;" (string #\newline)
		"  color: #000000;" (string #\newline)
		"  font-size: normal;" (string #\newline)
		"}" (string #\newline)
		"" (string #\newline)
		"" (string #\newline)
		".spod .text .itemindent {" (string #\newline)
		"	margin-left: -1em;" (string #\newline)
		"   margin-bottom: -0.5em;" (string #\newline)
		"}" (string #\newline)
		".spod .text .itemcolor {" (string #\newline)
		"	color: #205555;" (string #\newline)
		"}" (string #\newline)
		"" (string #\newline)
		".spod .text .indent1 {" (string #\newline)
		"	margin-left: 1em;" (string #\newline)
		"}" (string #\newline)
		"" (string #\newline)
		".spod .text .indent2 {" (string #\newline)
		"	margin-left: 2em;" (string #\newline)
		"}" (string #\newline)
		"" (string #\newline)
		".spod .text .indent3 {" (string #\newline)
		"	margin-left: 3em;" (string #\newline)
		"}" (string #\newline)
		"" (string #\newline)
		".spod .text .indent4 {" (string #\newline)
		"	margin-left: 4em;" (string #\newline)
		"}" (string #\newline)
		"" (string #\newline)
		".spod .text .indent5 {" (string #\newline)
		"	margin-left: 5em;" (string #\newline)
		"}" (string #\newline)
		"" (string #\newline)
		".spod .text .indent6 {" (string #\newline)
		"	margin-left: 6em;" (string #\newline)
		"}" (string #\newline)
		"" (string #\newline)
		".spod .text .indent7 {" (string #\newline)
		"	margin-left: 7em;" (string #\newline)
		"}" (string #\newline)
		"" (string #\newline)
		".spod .text IMG     {" (string #\newline)
		"  vertical-align: top;" (string #\newline)
		"}" (string #\newline)
		"" (string #\newline)
		".spod .text .header {" (string #\newline)
		"  text-decoration: none;" (string #\newline)
		"}" (string #\newline)
		"" (string #\newline)
		"" (string #\newline)
		"/* Table of contents */" (string #\newline)
		"" (string #\newline)
		".spod .toc A  {" (string #\newline)
		"  text-decoration: none;" (string #\newline)
		"}" (string #\newline)
		"" (string #\newline)
		".spod .toc .indent1 {" (string #\newline)
		"	margin-left: 1em;" (string #\newline)
		"}" (string #\newline)
		"" (string #\newline)
		".spod .toc .indent2 {" (string #\newline)
		"	margin-left: 2em;" (string #\newline)
		"}" (string #\newline)
		"" (string #\newline)
		".spod .toc .indent3 {" (string #\newline)
		"	margin-left: 3em;" (string #\newline)
		"}" (string #\newline)
		"" (string #\newline)
		".spod .toc .indent4 {" (string #\newline)
		"	margin-left: 4em;" (string #\newline)
		"}" (string #\newline)
		"" (string #\newline)
		".spod .toc .indent5 {" (string #\newline)
		"	margin-left: 5em;" (string #\newline)
		"}" (string #\newline)
		"" (string #\newline)
		".spod .toc .indent6 {" (string #\newline)
		"	margin-left: 6em;" (string #\newline)
		"}" (string #\newline)
		"" (string #\newline)
		".spod .toc .indent7 {" (string #\newline)
		"	margin-left: 7em;" (string #\newline)
		"}" (string #\newline)
		"" (string #\newline)
		".spod .toc LI {" (string #\newline)
		"  line-height: 1.2em;" (string #\newline)
		"  list-style-type: none;" (string #\newline)
		"}" (string #\newline)
		"" (string #\newline)
		".faq DT {" (string #\newline)
		"  font-size: 1.4em;" (string #\newline)
		"  font-weight: bold;" (string #\newline)
		"}" (string #\newline)
		"" (string #\newline)
		".chmenu {" (string #\newline)
		"  background: black;" (string #\newline)
		"  color: red;" (string #\newline)
		"  font: bold 1.1em Arial,Helvetica,sans-serif;" (string #\newline)
		"  margin: 1ex auto;" (string #\newline)
		"  padding: 0.5ex;" (string #\newline)
		"}" (string #\newline)
		"" (string #\newline)
		".chmenu TD {" (string #\newline)
		"  padding: 0.2ex 1ex;" (string #\newline)
		"}" (string #\newline)
		"" (string #\newline)
		".chmenu A:link, .chmenu A:visited  {" (string #\newline)
		"  background: transparent;" (string #\newline)
		"  color: white;" (string #\newline)
		"  text-decoration: none;" (string #\newline)
		"}" (string #\newline)
		"" (string #\newline)
		".chmenu A:hover {" (string #\newline)
		"  background: transparent;" (string #\newline)
		"  color: #ff6600;" (string #\newline)
		"  text-decoration: underline;" (string #\newline)
		"}" (string #\newline)
		"" (string #\newline)
		".column {" (string #\newline)
		"  padding: 0.5ex 1ex;" (string #\newline)
		"  vertical-align: top;" (string #\newline)
		"}" (string #\newline)
		"" (string #\newline)
		".datebar {" (string #\newline)
		"  margin: auto;" (string #\newline)
		"  width: 14em;" (string #\newline)
		"}" (string #\newline)
		"" (string #\newline)
		".date {" (string #\newline)
		"  background: transparent;" (string #\newline)
		"  color: #008000;" (string #\newline)
		"}" (string #\newline)
		"" (string #\newline)
		".tiny {" (string #\newline)
		"	font-size: 0.7em;" (string #\newline)
		"}" (string #\newline)
		))

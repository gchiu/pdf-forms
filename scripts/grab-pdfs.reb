rebol [
    file: %grab-pdfs.reb
    name: "Grab PDFs"
    date: 25-Jan-2020
    author: "Graham Chiu"
]

; Pharmac puts an index of all the Special authorities on this page
pdfs: https://schedule.pharmac.govt.nz/SAForms.php

; and this is their download directory
base: to url! unspaced [https://pharmac.govt.nz/ now/year "/" next form (100 + now/month) "/01/"]

; these are the drugs we use and are interested in.  Check their page (pdfs) to see what other drugs are supported
wanted: ["Adalimumab" "Etanercept" "Teriparatide" "Zoledronic acid inj 0.05 mg per ml, 100 ml" "Benzbromarone" "Tocilizumab"]

; as of August 2020 the pages are
; Adalimumab SA1950
; Etanercept SA1949
; Teriparatide SA1139
; Zolendronic Acid SA1780
; Benzbromarone SA1537
; Tocilizumab 1858

; read the page and turn into text for parsing out the download links
data: to text! read pdfs 

; store the data as pairs here
drugs: copy []

; this is what we have to parse out .. we want the pdf name, and the drug name
; <td><a href='/latest/SA1847.pdf'>SA1847 - Adalimumab</a> (20 pages, 235 KB)</td>

; parse the downloaded web page (data) and extract all the links we want
parse data [
    some [
        thru {<a href='/latest/} copy sa to {'} thru " - " copy name to </a> (
            ; dump name
            if find wanted name [
                append/only drugs reduce [name sa]
            ]
        )
    ]
]

; sample capture stored in the drugs block
; drugs [["Benzbromarone" "SA1537.pdf"] ["Teriparatide" "SA1139.pdf"] ["Adalimumab" "SA1847.pdf"] ["Etanercept" "SA1812.pdf"]]

; download each pdf and save it to the local filesystem 
print "downloading pdfs"
for-each pair drugs [
    probe pair/1
    print unspaced [base pair/2]
    write to file! pair/2 read to url! join base pair/2
]

; now convert each pdf to png and eps
print "converting pdfs to png and eps"
for-each pair drugs [
	; get the SAnnnn part of the pdf name
	pdf: pair/2
	root: copy/part pdf find pdf %.pdf
	
	; delete all extraneous png and eps files
	attempt [rm *.eps]
	attempt [rm *.png]
	
	script: unspaced ["gs -sDEVICE=pngmono -o " root "-%02d.png -r600 " pdf]
	; now convert to png using ghostscript
	call script
	
	; script: unspaced ["gs sDEVICE=eps2write -sPAPERSIZE=a4 -o " root "-%02d.eps " pdf]
	; split into separate pdfs eg. SA1234-01.pdf
	call unspaced ["pdfseparate " pdf space root "-%02d.pdf"]
	; now to convert each of the pdfs into eps
	n: 1
	forever [
		if exists? filename: to file! unspaced [root "-" next form 100 + n %.pdf][
			call unspaced ["pdftops -eps " filename]		
		] else [break]
		n: me + 1
	]
	call script
]

print "Finished job"

quit

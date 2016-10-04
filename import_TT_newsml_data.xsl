<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
	version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"	
	xmlns:xhtml="http://www.w3.org/1999/xhtml"
	 exclude-result-prefixes="xhtml xsl">
	
	<!-- XSLT som visar hur man kan konvertera TTNewsMLG2-version 2.20 till xml-filer för import som telegram i Newspilot. 
	       Telegramimporten sker i två delar där metadata hanteras av ett filter och själva innehållet av ett annat.
	       När det här filtret gjordes fanns det ingen funktionalitet för att markera att ett telegram ersätter ett tidigare telegram.
	       En del av det här kan behöva justeras för andra uppsättningar av Newspilot. Alla typer och id-nummer kanske inte matchar.
	       
	       (Den här behöver kompletteras med hantering av sportresultat och tabeller.)
	       
	       Johan Lindgren / TT / 2015-06-08

	       Version för sidverkstaden där mellanrubriker plockas bort 
	       2015-09-16 JL justerade ytterligare för sidverkstaden
	       2015-09-16 JL lade till hantering av aside notes
	       2015-09-23 JL Ändrade bildlänk och fixade med dateline
              2016-08-22 JL Kompletteringar inför införande av footer och h5
              2016-10-03 JL justering av visning av sportresultat
	-->

	<xsl:variable name="npdoc_ns">http://www.infomaker.se/npdoc/2.1</xsl:variable> <!-- NP vill ha namespace på alla element. -->
	
	<xsl:strip-space elements="*"/>
	
	<xsl:output encoding="UTF-8" indent="yes" method="xml" media-type="text/xml" omit-xml-declaration="no" version="1.0"/>

       <!-- Grund-template -->
	<xsl:template match="/">
		<xsl:element name="nptgr"> 
			
			<xsl:for-each select="//contentSet/inlineXML"> <!-- Gå igenom alla texter i filen -->
						
				<xsl:apply-templates select="./html/body"/> <!-- Utgå från body i html -->
				<xsl:apply-templates select="./article"></xsl:apply-templates>
			
			</xsl:for-each>
		</xsl:element>
	</xsl:template>
	
	
	<!-- Matcha article eller body -->
	<xsl:template match="body|article"> 
		<xsl:apply-templates/> <!-- Fortsätt ner i strukturen -->
	</xsl:template>
	
	<!-- Matcha sektion -->
	<xsl:template match="section">
		<npdoc version="2.1" xml:lang="sv" xmlns="http://www.infomaker.se/npdoc/2.1">
			<xsl:element name="headline" namespace="{$npdoc_ns}"><xsl:element name="p" namespace="{$npdoc_ns}"><xsl:value-of select="normalize-space(h1)"/></xsl:element></xsl:element>
			<xsl:element name="pagedateline" namespace="{$npdoc_ns}"><xsl:element name="p" namespace="{$npdoc_ns}"><xsl:value-of select="normalize-space(div[@class = 'dat']/span[@class = 'vignette'])"/></xsl:element></xsl:element>
			<xsl:element name="dateline" namespace="{$npdoc_ns}"><xsl:element name="p" namespace="{$npdoc_ns}"><xsl:value-of select="normalize-space(div[@class = 'dat']/span[@class = 'source'])"/></xsl:element></xsl:element>
			<xsl:apply-templates select="h4"/>   <!-- h4 är ingressen -->
			<xsl:element name="body" namespace="{$npdoc_ns}">
				<xsl:apply-templates select="div[@class = 'bodytext']"/>
				<xsl:apply-templates select="div[@class = 'byline']"/>
				<xsl:apply-templates select="footer[@class = 'broadcastinfo']"/>
				<xsl:if test="figure">
					<xsl:element name="p" namespace="{$npdoc_ns}"></xsl:element>
					<xsl:element name="p" namespace="{$npdoc_ns}"></xsl:element>
					<xsl:element name="p" namespace="{$npdoc_ns}"></xsl:element>
                                 <xsl:apply-templates select="figure"/>
				</xsl:if>
			</xsl:element>
		</npdoc>
	</xsl:template>
	
	<!-- Matcha sektioner som är av typen quotes -->
	<xsl:template match="section[@class = 'quotes']">
		<npdoc version="2.1" xml:lang="sv" xmlns="http://www.infomaker.se/npdoc/2.1">
			<xsl:element name="headline" namespace="{$npdoc_ns}"><xsl:element name="p" namespace="{$npdoc_ns}">(CITAT)</xsl:element></xsl:element>
			<xsl:apply-templates select="h4"/>
			<xsl:element name="body" namespace="{$npdoc_ns}">
			<xsl:apply-templates select="div[@class = 'bodytext']"/>
			<xsl:apply-templates select="div[@class = 'byline']"/>
				<xsl:if test="figure">
					<xsl:element name="p" namespace="{$npdoc_ns}"></xsl:element>
					<xsl:element name="p" namespace="{$npdoc_ns}"></xsl:element>
					<xsl:element name="p" namespace="{$npdoc_ns}"></xsl:element>
					<xsl:apply-templates select="figure"/>
				</xsl:if>
			</xsl:element>
		</npdoc>
	</xsl:template>

       <!-- Matcha asides som är facts -->
	<xsl:template match="aside[@class = 'facts']">
		<npdoc version="2.1" xml:lang="sv" xmlns="http://www.infomaker.se/npdoc/2.1">
			<xsl:element name="headline" namespace="{$npdoc_ns}"><xsl:element name="p" namespace="{$npdoc_ns}"><xsl:value-of select="normalize-space(h1)"/></xsl:element></xsl:element>
			<xsl:apply-templates select="h4"/>
			<xsl:element name="body" namespace="{$npdoc_ns}">
			<xsl:apply-templates select="div[@class = 'bodytext']"/>
			<xsl:apply-templates select="div[@class = 'byline']"/>
				<xsl:if test="figure">
					<xsl:element name="p" namespace="{$npdoc_ns}"></xsl:element>
					<xsl:element name="p" namespace="{$npdoc_ns}"></xsl:element>
					<xsl:element name="p" namespace="{$npdoc_ns}"></xsl:element>
					<xsl:apply-templates select="figure"/>
				</xsl:if>
			</xsl:element>
		</npdoc>
	</xsl:template>
	
	
	<!-- Matcha asides som är facts -->
	<xsl:template match="aside[@class = 'notes']">
		<npdoc version="2.1" xml:lang="sv" xmlns="http://www.infomaker.se/npdoc/2.1">
			<xsl:element name="headline" namespace="{$npdoc_ns}"><xsl:element name="p" namespace="{$npdoc_ns}"><xsl:value-of select="normalize-space(h1)"/></xsl:element></xsl:element>
			<xsl:apply-templates select="h4"/>
			<xsl:element name="body" namespace="{$npdoc_ns}">
				<xsl:apply-templates select="div[@class = 'bodytext']"/>
				<xsl:apply-templates select="div[@class = 'byline']"/>
				<xsl:apply-templates select="footer[@class = 'broadcastinfo']"/>
				<xsl:if test="figure">
					<xsl:element name="p" namespace="{$npdoc_ns}"></xsl:element>
					<xsl:element name="p" namespace="{$npdoc_ns}"></xsl:element>
					<xsl:element name="p" namespace="{$npdoc_ns}"></xsl:element>
					<xsl:apply-templates select="figure"/>
				</xsl:if>
			</xsl:element>
		</npdoc>
	</xsl:template>
	
	<!-- Start av sportresultat -->
	<xsl:template match="section[@class = 'sport']">
		<npdoc version="2.1" xml:lang="sv" xmlns="http://www.infomaker.se/npdoc/2.1">
			<xsl:element name="headline" namespace="{$npdoc_ns}"><xsl:element name="p" namespace="{$npdoc_ns}"><xsl:value-of select="normalize-space(concat(h1[@class = 'sport-location'],' ',h1[@class = 'sport-what']))"/></xsl:element></xsl:element>
			<xsl:element name="pagedateline" namespace="{$npdoc_ns}"><xsl:element name="p" namespace="{$npdoc_ns}"><xsl:value-of select="normalize-space(h1[@class = 'sport-discipline'])"/></xsl:element></xsl:element>
			<xsl:element name="dateline" namespace="{$npdoc_ns}"><xsl:element name="p" namespace="{$npdoc_ns}">TT</xsl:element></xsl:element>
			<xsl:element name="body" namespace="{$npdoc_ns}">
				<xsl:apply-templates/>
			</xsl:element>
		</npdoc>
	</xsl:template>
	
	<xsl:template match="h1[@class = 'sport-location']"></xsl:template>
	<xsl:template match="h1[@class = 'sport-what']"></xsl:template>
	<xsl:template match="h1[@class = 'sport-discipline']"></xsl:template>
	
	<!-- Start av sportresultat -->
	<xsl:template match="div[@class = 'sport']">
		<npdoc version="2.1" xml:lang="sv" xmlns="http://www.infomaker.se/npdoc/2.1">
			<xsl:element name="headline" namespace="{$npdoc_ns}"><xsl:element name="p" namespace="{$npdoc_ns}"><xsl:value-of select="normalize-space(concat(h4[@class = 'sport-location'],' ',h4[@class = 'sport-what']))"/></xsl:element></xsl:element>
			<xsl:element name="pagedateline" namespace="{$npdoc_ns}"><xsl:element name="p" namespace="{$npdoc_ns}"><xsl:value-of select="normalize-space(h3[@class = 'sport-discipline'])"/></xsl:element></xsl:element>
			<xsl:element name="dateline" namespace="{$npdoc_ns}"><xsl:element name="p" namespace="{$npdoc_ns}">TT</xsl:element></xsl:element>
			<xsl:element name="body" namespace="{$npdoc_ns}">
				<xsl:apply-templates select="section"/>
			</xsl:element>
		</npdoc>
	</xsl:template>

	<!-- Separata templates för de olika delarna i HTML5 -->
	
	<xsl:template match="h4">
		<xsl:element name="leadin" namespace="{$npdoc_ns}"><xsl:apply-templates mode="ingress"/></xsl:element>  <!-- Skapa ingressstart som är leadin och bearbeta allt däri -->
	</xsl:template>
	
	
	<xsl:template match="p" mode="ingress">
		<xsl:element name="p" namespace="{$npdoc_ns}"><xsl:value-of select="normalize-space(.)"/></xsl:element>
	</xsl:template>
	
	<xsl:template match="blockquote" mode="ingress">
		<xsl:element name="p" namespace="{$npdoc_ns}"><xsl:text>&#x2013; </xsl:text><xsl:value-of select="normalize-space(.)"/></xsl:element>
	</xsl:template>
	
	<xsl:template match="div[@class = 'bodytext']"><xsl:apply-templates/></xsl:template>
	
	<xsl:template match="footer[@class = 'broadcastinfo']">
		<xsl:for-each select="./p">
			<xsl:element name="p" namespace="{$npdoc_ns}"><xsl:value-of select="normalize-space(.)"/></xsl:element>
		</xsl:for-each>
	</xsl:template>
	
	<xsl:template match="p">
		<xsl:choose>
			<xsl:when test=". = 'Kommande matcher:'"><xsl:element name="p" namespace="{$npdoc_ns}"><xsl:element name="b" namespace="{$npdoc_ns}">Kommande matcher:</xsl:element></xsl:element></xsl:when>
			<xsl:when test="position() = last() and ../../div[@class= 'dat']/span[@class = 'source'] != '' and ../../div[@class= 'byline'] = ''"><xsl:element name="p" namespace="{$npdoc_ns}"><xsl:value-of select="normalize-space(.)"/><xsl:value-of select="concat(' (',../../div[@class= 'dat']/span[@class = 'source'],') ')"/></xsl:element></xsl:when>
			<xsl:otherwise><xsl:element name="p" namespace="{$npdoc_ns}"><xsl:value-of select="normalize-space(.)"/></xsl:element></xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="blockquote">
		<xsl:choose>
			<xsl:when test="position() = last() and ../../div[@class= 'dat']/span[@class = 'source'] != '' and ../../div[@class= 'byline'] = ''"><xsl:element name="p" namespace="{$npdoc_ns}"><xsl:text>&#x2013; </xsl:text><xsl:value-of select="normalize-space(.)"/><xsl:value-of select="concat(' (',../../div[@class= 'dat']/span[@class = 'source'],') ')"/></xsl:element></xsl:when>
			<xsl:otherwise><xsl:element name="p" namespace="{$npdoc_ns}"><xsl:text>&#x2013; </xsl:text><xsl:value-of select="normalize-space(.)"/></xsl:element></xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="div[@class = 'bodytext']"><xsl:apply-templates/></xsl:template>
	
	<xsl:template match="div[@class = 'byline']">
		<xsl:element name="p" namespace="{$npdoc_ns}"><xsl:value-of select="normalize-space(.)"/></xsl:element>
	</xsl:template>
	
	<xsl:template match="h2">
		<xsl:element name="subheadline1" namespace="{$npdoc_ns}"><xsl:value-of select="normalize-space(.)"/></xsl:element>
	</xsl:template>
	
	<xsl:template match="h5[@class = 'question']">
		<xsl:element name="subheadline1" namespace="{$npdoc_ns}"><xsl:value-of select="normalize-space(.)"/></xsl:element>
	</xsl:template>

	<xsl:template match="figure">
		<xsl:element name="p" namespace="{$npdoc_ns}"><xsl:value-of select="normalize-space(figcaption)"/></xsl:element>
		<xsl:element name="p" namespace="{$npdoc_ns}"><xsl:value-of select="concat('Foto: ',normalize-space(div[@class = 'byline']))"/></xsl:element>
		<xsl:element name="p" namespace="{$npdoc_ns}"><xsl:element name="a" namespace="{$npdoc_ns}"><xsl:attribute name="href"><xsl:value-of select="normalize-space(img/@data-uri)"/></xsl:attribute><xsl:value-of select="normalize-space(img/@data-uri)"/></xsl:element></xsl:element>
	</xsl:template>
	
	<xsl:template match="table">
		
		<xsl:for-each select="tr"><xsl:element name="subheadline4" namespace="{$npdoc_ns}"><xsl:attribute name="customName">Tabell</xsl:attribute>
			<xsl:for-each select="td"><xsl:if test=". != ''"><xsl:text>&#9;</xsl:text><xsl:value-of select="."/></xsl:if></xsl:for-each></xsl:element></xsl:for-each>
	</xsl:template>
	
	<xsl:template match="ul">
		<xsl:for-each select="li"><xsl:element name="subheadline5" namespace="{$npdoc_ns}"><xsl:attribute name="customName">Lista</xsl:attribute><xsl:value-of select="."/></xsl:element></xsl:for-each>
	</xsl:template>
	
	<!-- Sportresultat i HTML5 -->
	
	<xsl:template match="section[@class = 'result']">
		<xsl:choose>
			<xsl:when test=" count(./div[@class = 'result-txt']/p) = 1">
				<xsl:element name="p" namespace="{$npdoc_ns}">
					<xsl:if test="normalize-space(h4[@class = 'result-vad']) != ''">
						<xsl:element name="b" namespace="{$npdoc_ns}">
							<xsl:value-of select="normalize-space(h4[@class = 'result-vad'])"/>: </xsl:element>
					</xsl:if>
					<xsl:value-of select="div[@class = 'result-txt']"/>
				</xsl:element>
				
			</xsl:when>
			<xsl:otherwise>
				<xsl:if test="normalize-space(h4[@class = 'result-vad']) != ''">
					<xsl:element name="p" namespace="{$npdoc_ns}">
						<xsl:element name="b" namespace="{$npdoc_ns}">
							<xsl:value-of select="normalize-space(h4[@class = 'result-vad'])"/>: </xsl:element>
					</xsl:element>
				</xsl:if>
				<xsl:for-each select="div[@class = 'result-txt']/p">
					<xsl:choose>
						<xsl:when test=" starts-with(.,'Bomben') or starts-with(.,'Matchen')">
							<xsl:element name="p" namespace="{$npdoc_ns}">
								<xsl:element name="b" namespace="{$npdoc_ns}">
									<xsl:value-of select="normalize-space(.)"/></xsl:element>
							</xsl:element>
							
						</xsl:when>
						<xsl:otherwise>
							<xsl:element name="p" namespace="{$npdoc_ns}">
								<xsl:value-of select="normalize-space(.)"/> 
							</xsl:element>
							
						</xsl:otherwise>
					</xsl:choose>
				</xsl:for-each>
				
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="section[@class ='result-epa']">
		<xsl:element name="p" namespace="{$npdoc_ns}"><xsl:element name="b" namespace="{$npdoc_ns}"><xsl:value-of select="normalize-space(concat(span[@class = 'result-hlag'],'–',span[@class = 'result-blag'],' ',span[@class = 'result-hres'],'–',span[@class = 'result-bres'],' ',p[@class = 'result-epa-period']))"/></xsl:element></xsl:element>
		<xsl:apply-templates select="p[@class = 'result-epa-fakta']"></xsl:apply-templates>
	</xsl:template>
	
	<xsl:template match="p[@class ='result-epa-fakta']">
		<xsl:apply-templates select="p" mode="fakta"></xsl:apply-templates>
	</xsl:template>




<xsl:template match="p" mode="fakta">
		<xsl:choose>
			<xsl:when test="contains(.,'Publik:')"><xsl:element name="p" namespace="{$npdoc_ns}"><xsl:element name="b" namespace="{$npdoc_ns}">Publik:</xsl:element><xsl:value-of select="substring-after(.,'Publik:')"/></xsl:element></xsl:when>
			<xsl:otherwise><xsl:element name="p" namespace="{$npdoc_ns}"><xsl:value-of select="normalize-space(.)"/></xsl:element></xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="section[@class ='result-tab']">
		<xsl:choose>
			<xsl:when test="./table/@class = 'serietab'"><xsl:apply-templates/></xsl:when>
			<xsl:otherwise><xsl:apply-templates mode="resulttab"/></xsl:otherwise>
		</xsl:choose>
		
	</xsl:template>

	<xsl:template match="table" mode="resulttab">
		<xsl:for-each select="tr">
			<xsl:element name="subheadline4" namespace="{$npdoc_ns}"><xsl:attribute name="customName">Tabell</xsl:attribute>
				<xsl:for-each select="td"><xsl:text>&#9;</xsl:text><xsl:value-of select="."/></xsl:for-each>
			</xsl:element>
		</xsl:for-each>
	</xsl:template>
	

	<xsl:template match="table[@class ='serietab']">
		<xsl:apply-templates mode="serietab"/>
	</xsl:template>
	
	<xsl:template match="h4" mode="serietab">
		<xsl:element name="subheadline1" namespace="{$npdoc_ns}"><xsl:value-of select="normalize-space(.)"/></xsl:element>
	</xsl:template>

       <xsl:template match="thead" mode="serietab">
       	<xsl:element name="subheadline4" namespace="{$npdoc_ns}"><xsl:attribute name="customName">Tabell</xsl:attribute>
       		<xsl:text>&#9;Lag</xsl:text>
       		<xsl:text>&#9;&#9;</xsl:text><xsl:value-of select="./tr/td[@class = 'hv']"/>
       		<xsl:text>&#9;&#9;&#9;&#9;</xsl:text><xsl:value-of select="./tr/td[@class = 'bv']"/>
       		<xsl:text>&#9;&#9;&#9;&#9;&#9;</xsl:text><xsl:value-of select="./tr/td[@class = 'sm']"/>
       	</xsl:element>
       </xsl:template>

       <xsl:template match="tbody" mode="serietab">
       	<xsl:for-each select="tr">
       		<xsl:choose>
       			<xsl:when test="./@class = 'splinje'"><xsl:element name="subheadline1" namespace="{$npdoc_ns}">----------------------------------------</xsl:element></xsl:when>
       			<xsl:otherwise>
       				<xsl:element name="subheadline4" namespace="{$npdoc_ns}"><xsl:attribute name="customName">Tabell</xsl:attribute>
       					<xsl:for-each select="td">
       						<xsl:choose>
       							<xsl:when test="./@class = 'im' or ./@class = 'hi' or ./@class = 'bi'"><xsl:text>-</xsl:text><xsl:value-of select="."/></xsl:when>
       							<xsl:otherwise><xsl:text>&#9;</xsl:text><xsl:value-of select="."/></xsl:otherwise>
       						</xsl:choose>
       					</xsl:for-each>
       				</xsl:element>
       			</xsl:otherwise>
       		</xsl:choose>
       	</xsl:for-each>
       </xsl:template>

	<xsl:template match="div[@class ='tabinfo']">
		<xsl:element name="p" namespace="{$npdoc_ns}">  </xsl:element>
		<xsl:apply-templates></xsl:apply-templates>
	</xsl:template>
	

	
	<!-- Sportresultat i HTML5 -->
	
	<xsl:template match="section[@class = 'result']">
		<xsl:choose>
			<xsl:when test=" count(./div[@class = 'result-txt']/p) = 1">
				<xsl:element name="p" namespace="{$npdoc_ns}">
					<xsl:if test="normalize-space(h4[@class = 'result-vad']) != ''">
						<xsl:element name="b" namespace="{$npdoc_ns}">
							<xsl:value-of select="normalize-space(h4[@class = 'result-vad'])"/>: </xsl:element>
					</xsl:if>
					<xsl:value-of select="div[@class = 'result-txt']"/>
				</xsl:element>
				
			</xsl:when>
			<xsl:otherwise>
				<xsl:if test="normalize-space(h4[@class = 'result-vad']) != ''">
					<xsl:element name="p" namespace="{$npdoc_ns}">
						<xsl:element name="b" namespace="{$npdoc_ns}">
							<xsl:value-of select="normalize-space(h4[@class = 'result-vad'])"/>: </xsl:element>
					</xsl:element>
				</xsl:if>
				<xsl:for-each select="div[@class = 'result-txt']/p">
					<xsl:choose>
						<xsl:when test=" starts-with(.,'Bomben') or starts-with(.,'Matchen')">
							<xsl:element name="p" namespace="{$npdoc_ns}">
								<xsl:element name="b" namespace="{$npdoc_ns}">
									<xsl:value-of select="normalize-space(.)"/></xsl:element>
							</xsl:element>
							
						</xsl:when>
						<xsl:otherwise>
							<xsl:element name="p" namespace="{$npdoc_ns}">
								<xsl:value-of select="normalize-space(.)"/> 
							</xsl:element>
							
						</xsl:otherwise>
					</xsl:choose>
				</xsl:for-each>
				
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="section[@class ='result-epa']">
		<xsl:element name="p" namespace="{$npdoc_ns}"><xsl:element name="b" namespace="{$npdoc_ns}"><xsl:value-of select="normalize-space(concat(span[@class = 'result-hlag'],'–',span[@class = 'result-blag'],' ',span[@class = 'result-hres'],'–',span[@class = 'result-bres'],' ',p[@class = 'result-epa-period']))"/></xsl:element></xsl:element>
		<xsl:apply-templates select="p[@class = 'result-epa-fakta']"></xsl:apply-templates>
	</xsl:template>
	
	<xsl:template match="p[@class ='result-epa-fakta']">
		<xsl:apply-templates select="p" mode="fakta"></xsl:apply-templates>
	</xsl:template>




<xsl:template match="p" mode="fakta">
		<xsl:choose>
			<xsl:when test="contains(.,'Publik:')"><xsl:element name="p" namespace="{$npdoc_ns}"><xsl:element name="b" namespace="{$npdoc_ns}">Publik:</xsl:element><xsl:value-of select="substring-after(.,'Publik:')"/></xsl:element></xsl:when>
			<xsl:otherwise><xsl:element name="p" namespace="{$npdoc_ns}"><xsl:value-of select="normalize-space(.)"/></xsl:element></xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="section[@class ='result-tab']">
		<xsl:choose>
			<xsl:when test="./table/@class = 'serietab'"><xsl:apply-templates/></xsl:when>
			<xsl:otherwise><xsl:apply-templates mode="resulttab"/></xsl:otherwise>
		</xsl:choose>
		
	</xsl:template>

	<xsl:template match="table" mode="resulttab">
		<xsl:for-each select="tr">
			<xsl:element name="subheadline4" namespace="{$npdoc_ns}"><xsl:attribute name="customName">Tabell</xsl:attribute>
				<xsl:for-each select="td"><xsl:text>&#9;</xsl:text><xsl:value-of select="."/></xsl:for-each>
			</xsl:element>
		</xsl:for-each>
	</xsl:template>
	

	<xsl:template match="table[@class ='serietab']">
		<xsl:apply-templates mode="serietab"/>
	</xsl:template>
	
	<xsl:template match="h4" mode="serietab">
		<xsl:element name="subheadline1" namespace="{$npdoc_ns}"><xsl:value-of select="normalize-space(.)"/></xsl:element>
	</xsl:template>

       <xsl:template match="thead" mode="serietab">
       	<xsl:element name="subheadline4" namespace="{$npdoc_ns}"><xsl:attribute name="customName">Tabell</xsl:attribute>
       		<xsl:text>&#9;Lag</xsl:text>
       		<xsl:text>&#9;&#9;</xsl:text><xsl:value-of select="./tr/td[@class = 'hv']"/>
       		<xsl:text>&#9;&#9;&#9;&#9;</xsl:text><xsl:value-of select="./tr/td[@class = 'bv']"/>
       		<xsl:text>&#9;&#9;&#9;&#9;&#9;</xsl:text><xsl:value-of select="./tr/td[@class = 'sm']"/>
       	</xsl:element>
       </xsl:template>

       <xsl:template match="tbody" mode="serietab">
       	<xsl:for-each select="tr">
       		<xsl:choose>
       			<xsl:when test="./@class = 'splinje'"><xsl:element name="subheadline1" namespace="{$npdoc_ns}">----------------------------------------</xsl:element></xsl:when>
       			<xsl:otherwise>
       				<xsl:element name="subheadline4" namespace="{$npdoc_ns}"><xsl:attribute name="customName">Tabell</xsl:attribute>
       					<xsl:for-each select="td">
       						<xsl:choose>
       							<xsl:when test="./@class = 'im' or ./@class = 'hi' or ./@class = 'bi'"><xsl:text>-</xsl:text><xsl:value-of select="."/></xsl:when>
       							<xsl:otherwise><xsl:text>&#9;</xsl:text><xsl:value-of select="."/></xsl:otherwise>
       						</xsl:choose>
       					</xsl:for-each>
       				</xsl:element>
       			</xsl:otherwise>
       		</xsl:choose>
       	</xsl:for-each>
       </xsl:template>

	<xsl:template match="div[@class ='tabinfo']">
		<xsl:element name="p" namespace="{$npdoc_ns}">  </xsl:element>
		<xsl:apply-templates></xsl:apply-templates>
	</xsl:template>
	


</xsl:stylesheet>

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
              2016-11-03 JL Ytterligare kompletteringar för sportresultat
	-->

	<xsl:variable name="npdoc_ns">http://www.infomaker.se/npdoc/2.1</xsl:variable> <!-- NP vill ha namespace på alla element. -->
	
	<xsl:strip-space elements="*"/>
	
	<xsl:output encoding="UTF-8" indent="yes" method="xml" media-type="text/xml" omit-xml-declaration="no" version="1.0"/>

       <!-- Grund-template -->
	<xsl:template match="/">
		<xsl:element name="nptgr"> 
			
			<xsl:for-each select="//contentSet/inlineXML"> <!-- Gå igenom alla texter i filen -->
						
				<xsl:apply-templates select="./html/body"/> <!-- Utgå från body i html -->
				<xsl:apply-templates select="./article"/> <!-- Tidigare förekom det versioner som började direkt med article -->
			
			</xsl:for-each>
		</xsl:element>
	</xsl:template>
	
	
	<!-- Matcha article eller body -->
	<xsl:template match="body|article"> 
		<xsl:apply-templates/> <!-- Fortsätt ner i strukturen -->
	</xsl:template>
	
	
	<!-- Matcha sektion som inte har något class-attribut-->
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
	
	
	<!-- Matcha asides som är notes -->
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
	<!-- Section som har class sport -->
	<xsl:template match="section[@class = 'sport']">
		<npdoc version="2.1" xml:lang="sv" xmlns="http://www.infomaker.se/npdoc/2.1">
			<xsl:element name="headline" namespace="{$npdoc_ns}"><xsl:element name="p" namespace="{$npdoc_ns}"><xsl:value-of select="normalize-space(concat(h1[@class = 'sport-location'],' ',h1[@class = 'sport-what']))"/></xsl:element></xsl:element>
			<xsl:element name="pagedateline" namespace="{$npdoc_ns}"><xsl:element name="p" namespace="{$npdoc_ns}"><xsl:value-of select="normalize-space(h1[@class = 'sport-discipline'])"/></xsl:element></xsl:element>
			<xsl:element name="dateline" namespace="{$npdoc_ns}"><xsl:element name="p" namespace="{$npdoc_ns}">TT</xsl:element></xsl:element>
			<xsl:element name="body" namespace="{$npdoc_ns}">
				<xsl:apply-templates/> <!-- Gå igenom resten i sport-sektionen -->
			</xsl:element>
		</npdoc>
	</xsl:template>
	
	
	<!-- Dom här hanterar vi på annat sätt så vi har dom tomma här så de inte kommer med som lös text -->
	<xsl:template match="h1[@class = 'sport-location']"></xsl:template>
	<xsl:template match="h1[@class = 'sport-what']"></xsl:template>
	<xsl:template match="h1[@class = 'sport-discipline']"></xsl:template>
	
	<!-- Den här ska inte förekomma längre och kan på sikt tas bort -->
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
	
	<!-- Först element som har element inuti -->
	
	<!-- Vi använder h4 för att indikera att det är ingressen och har då element i h4 -->
	<xsl:template match="h4">
		<xsl:element name="leadin" namespace="{$npdoc_ns}"><xsl:apply-templates mode="ingress"/></xsl:element>  <!-- Skapa ingressstart som är leadin och bearbeta allt däri -->
	</xsl:template>
	
	<!-- div som är class bodytext -->
	<xsl:template match="div[@class = 'bodytext']"><xsl:apply-templates/></xsl:template>
	
	<!-- div som är class byline -->	
	<xsl:template match="div[@class = 'byline']">
		<xsl:element name="p" namespace="{$npdoc_ns}"><xsl:value-of select="normalize-space(.)"/></xsl:element>
	</xsl:template>
	
	
	<!-- Element som kan förekomma i ingressen/h4 -->
	
	<!-- p-element i ingressen -->
	<xsl:template match="p" mode="ingress">
		<xsl:element name="p" namespace="{$npdoc_ns}"><xsl:value-of select="normalize-space(.)"/></xsl:element>
	</xsl:template>
	
	<!-- blockquote i ingressen -->
	<xsl:template match="blockquote" mode="ingress">
		<xsl:element name="p" namespace="{$npdoc_ns}"><xsl:text>&#x2013; </xsl:text><xsl:value-of select="normalize-space(.)"/></xsl:element>
	</xsl:template>
	
	<!-- Övriga element -->
 
	<!-- footer med class broadcastinfo kan användas i texter som handlar om tv-program -->
	<xsl:template match="footer[@class = 'broadcastinfo']">
		<xsl:for-each select="./p">
			<xsl:element name="p" namespace="{$npdoc_ns}"><xsl:value-of select="normalize-space(.)"/></xsl:element>
		</xsl:for-each>
	</xsl:template>
	
	<!-- Vanliga p som inte fångas upp på annat sätt -->
	<xsl:template match="p">
		<xsl:choose>
			<xsl:when test=". = 'Kommande matcher:'"><xsl:element name="p" namespace="{$npdoc_ns}"><xsl:element name="b" namespace="{$npdoc_ns}">Kommande matcher:</xsl:element></xsl:element></xsl:when>
			<xsl:when test="position() = last() and ../../div[@class= 'dat']/span[@class = 'source'] != '' and ../../div[@class= 'byline'] = ''"><xsl:element name="p" namespace="{$npdoc_ns}"><xsl:value-of select="normalize-space(.)"/><xsl:value-of select="concat(' (',../../div[@class= 'dat']/span[@class = 'source'],') ')"/></xsl:element></xsl:when>
			<xsl:otherwise><xsl:element name="p" namespace="{$npdoc_ns}"><xsl:value-of select="normalize-space(.)"/></xsl:element></xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- Vanliga blockquote som inte fångas upp på annat sätt -->
	<xsl:template match="blockquote">
		<xsl:choose>
			<xsl:when test="position() = last() and ../../div[@class= 'dat']/span[@class = 'source'] != '' and ../../div[@class= 'byline'] = ''"><xsl:element name="p" namespace="{$npdoc_ns}"><xsl:text>&#x2013; </xsl:text><xsl:value-of select="normalize-space(.)"/><xsl:value-of select="concat(' (',../../div[@class= 'dat']/span[@class = 'source'],') ')"/></xsl:element></xsl:when>
			<xsl:otherwise><xsl:element name="p" namespace="{$npdoc_ns}"><xsl:text>&#x2013; </xsl:text><xsl:value-of select="normalize-space(.)"/></xsl:element></xsl:otherwise>
		</xsl:choose>
	</xsl:template>

       <!-- h2 är mellanrubriker -->
	<xsl:template match="h2">
		<xsl:element name="subheadline1" namespace="{$npdoc_ns}"><xsl:value-of select="normalize-space(.)"/></xsl:element>
	</xsl:template>
	
	<!-- h5 med class question är sk FRAGA -->
	<xsl:template match="h5[@class = 'question']">
		<xsl:element name="subheadline1" namespace="{$npdoc_ns}"><xsl:value-of select="normalize-space(.)"/></xsl:element>
	</xsl:template>

       <!-- Bildhänvisningar -->
	<xsl:template match="figure">
		<xsl:element name="p" namespace="{$npdoc_ns}"><xsl:value-of select="normalize-space(figcaption)"/></xsl:element>
		<xsl:element name="p" namespace="{$npdoc_ns}"><xsl:value-of select="concat('Foto: ',normalize-space(div[@class = 'byline']))"/></xsl:element>
		<xsl:element name="p" namespace="{$npdoc_ns}"><xsl:element name="a" namespace="{$npdoc_ns}"><xsl:attribute name="href"><xsl:value-of select="normalize-space(img/@data-uri)"/></xsl:attribute><xsl:value-of select="normalize-space(img/@data-uri)"/></xsl:element></xsl:element>
	</xsl:template>
	
       <!-- Generella tabeller -->	
	<xsl:template match="table">
		<xsl:for-each select="tr"><xsl:element name="subheadline4" namespace="{$npdoc_ns}"><xsl:attribute name="customName">Tabell</xsl:attribute>
			<xsl:for-each select="td"><xsl:if test=". != ''"><xsl:text>&#9;</xsl:text><xsl:value-of select="."/></xsl:if></xsl:for-each></xsl:element></xsl:for-each>
	</xsl:template>
	
	<!-- Oordnade listor -->
	<xsl:template match="ul">
		<xsl:for-each select="li"><xsl:element name="subheadline5" namespace="{$npdoc_ns}"><xsl:attribute name="customName">Lista</xsl:attribute><xsl:value-of select="."/></xsl:element></xsl:for-each>
	</xsl:template>
	
	
	<!-- Sportresultat i HTML5 -->
	
	<!-- div som har class result. div är det rätta -->
	<xsl:template match="div[@class = 'result']">
		<xsl:choose>
			<xsl:when test=" count(./div[@class = 'result-txt']/p) = 1">  <!-- Om vi bara har en div med result-txt så  -->
				<xsl:element name="p" namespace="{$npdoc_ns}">        <!-- skapar vi en p -->
					<xsl:if test="normalize-space(h2[@class = 'result-vad']) != ''"> <!-- och lägger eventuell h2 som bold först i den -->
						<xsl:element name="b" namespace="{$npdoc_ns}">
							<xsl:value-of select="normalize-space(h2[@class = 'result-vad'])"/><xsl:text>: </xsl:text></xsl:element>
					</xsl:if>
					<xsl:value-of select="div[@class = 'result-txt']"/>
				</xsl:element>
			</xsl:when>
			<xsl:otherwise>  <!-- Annars har vi flera div av class result-txt -->
				<xsl:if test="normalize-space(h2[@class = 'result-vad']) != ''"> <!-- Om vi då har en h2 så får den en egen p -->
					<xsl:element name="subheadline1" namespace="{$npdoc_ns}">
							<xsl:value-of select="normalize-space(h2[@class = 'result-vad'])"/><xsl:text>: </xsl:text>
					</xsl:element>
				</xsl:if>
				<xsl:for-each select="div[@class = 'result-txt']/p">  <!-- Sen går vi igenom alla div class=result-txt i denna result -->
					<xsl:choose>
						<xsl:when test=" starts-with(.,'Bomben') or starts-with(.,'Matchen')"> <!-- Om det är bomben eller matchen -->
							<xsl:element name="p" namespace="{$npdoc_ns}">
								<xsl:element name="b" namespace="{$npdoc_ns}">
									<xsl:value-of select="normalize-space(.)"/></xsl:element>
							</xsl:element>
						</xsl:when>
						<xsl:otherwise> <!-- Annars -->
							<xsl:element name="p" namespace="{$npdoc_ns}">
								<xsl:choose>
									<xsl:when test="starts-with(.,'Komb:')"><xsl:element name="b" namespace="{$npdoc_ns}">Komb:</xsl:element><xsl:value-of select="substring-after(.,'Komb:')"/></xsl:when>
									<xsl:when test="starts-with(.,'Odds:')"><xsl:element name="b" namespace="{$npdoc_ns}">Odds:</xsl:element><xsl:value-of select="substring-after(.,'Odds:')"/></xsl:when>
									<xsl:when test="starts-with(.,'Oms:')"><xsl:element name="b" namespace="{$npdoc_ns}">Oms:</xsl:element><xsl:value-of select="substring-after(.,'Oms:')"/></xsl:when>
									<xsl:otherwise><xsl:value-of select="normalize-space(.)"/></xsl:otherwise>
								</xsl:choose>
							</xsl:element>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:for-each>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
       <!-- div av typen result-epa. div är det korrekta -->
	<xsl:template match="div[@class ='result-epa']">
		<xsl:element name="subheadline1" namespace="{$npdoc_ns}">
			<xsl:value-of select="normalize-space(concat(span[@class = 'result-hlag'],'–',span[@class = 'result-blag'],' ',span[@class = 'result-hres'],'–',span[@class = 'result-bres'],' ',p[@class = 'result-epa-period']))"/>
		</xsl:element>
		<xsl:apply-templates select="p[@class = 'result-epa-fakta']"/>
	</xsl:template>
	
       <!-- div  med class result-tab. div är det korrekta -->
	<xsl:template match="div[@class ='result-tab']">
		<xsl:choose>
			<xsl:when test="./table/@class = 'serietab'"><xsl:apply-templates/></xsl:when>
			<xsl:otherwise><xsl:apply-templates mode="resulttab"/></xsl:otherwise>
		</xsl:choose>
	</xsl:template>




	<!-- I den här konstruktionen har vi en p som övergripande och vanliga p inuti. -->
	<xsl:template match="p[@class ='result-epa-fakta']">
		<xsl:apply-templates select="p" mode="fakta"/>
	</xsl:template>

       <!-- Här fångar vi de p som finns i result-epa-fakta -->
	<xsl:template match="p" mode="fakta">
		<xsl:choose>
			<xsl:when test="starts-with(.,'Första perioden:')"><xsl:element name="p" namespace="{$npdoc_ns}"><xsl:element name="b" namespace="{$npdoc_ns}">Första perioden:</xsl:element><xsl:value-of select="substring-after(.,'Första perioden:')"/></xsl:element></xsl:when>
			<xsl:when test="starts-with(.,'Andra perioden:')"><xsl:element name="p" namespace="{$npdoc_ns}"><xsl:element name="b" namespace="{$npdoc_ns}">Andra perioden:</xsl:element><xsl:value-of select="substring-after(.,'Andra perioden:')"/></xsl:element></xsl:when>
			<xsl:when test="starts-with(.,'Tredje perioden:')"><xsl:element name="p" namespace="{$npdoc_ns}"><xsl:element name="b" namespace="{$npdoc_ns}">Tredje perioden:</xsl:element><xsl:value-of select="substring-after(.,'Tredje perioden:')"/></xsl:element></xsl:when>
			<xsl:when test="starts-with(.,'Publik:')"><xsl:element name="p" namespace="{$npdoc_ns}"><xsl:element name="b" namespace="{$npdoc_ns}">Publik:</xsl:element><xsl:value-of select="substring-after(.,'Publik:')"/></xsl:element></xsl:when>
			<xsl:when test="starts-with(.,'Skott:')"><xsl:element name="p" namespace="{$npdoc_ns}"><xsl:element name="b" namespace="{$npdoc_ns}">Skott:</xsl:element><xsl:value-of select="substring-after(.,'Skott:')"/></xsl:element></xsl:when>
			<xsl:when test="starts-with(.,'Utv,')"><xsl:element name="p" namespace="{$npdoc_ns}"><xsl:element name="b" namespace="{$npdoc_ns}">Utv,</xsl:element><xsl:value-of select="substring-after(.,'Utv,')"/></xsl:element></xsl:when>
			<xsl:when test="starts-with(.,'Domare:')"><xsl:element name="p" namespace="{$npdoc_ns}"><xsl:element name="b" namespace="{$npdoc_ns}">Domare:</xsl:element><xsl:value-of select="substring-after(.,'Domare:')"/></xsl:element></xsl:when>
			<xsl:otherwise><xsl:element name="p" namespace="{$npdoc_ns}"><xsl:value-of select="normalize-space(.)"/></xsl:element></xsl:otherwise>
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
		<xsl:element name="p" namespace="{$npdoc_ns}"/>
		<xsl:apply-templates mode="serietab"/>
	</xsl:template>
	
	<xsl:template match="caption" mode="serietab">
		<xsl:element name="subheadline1" namespace="{$npdoc_ns}"><xsl:value-of select="normalize-space(.)"/></xsl:element>
	</xsl:template>

       <xsl:template match="thead" mode="serietab">
       	<xsl:element name="subheadline4" namespace="{$npdoc_ns}"><xsl:attribute name="customName">Tabell</xsl:attribute>
       		<xsl:element name="b" namespace="{$npdoc_ns}"><xsl:text>Lag</xsl:text></xsl:element>
       		<xsl:element name="b" namespace="{$npdoc_ns}"><xsl:text>&#9;&#9;</xsl:text><xsl:value-of select="./tr/td[@class = 'hv']"/></xsl:element>
      			<xsl:element name="b" namespace="{$npdoc_ns}"><xsl:text>&#9;&#9;&#9;&#9;</xsl:text><xsl:value-of select="./tr/td[@class = 'bv']"/></xsl:element>
   			<xsl:element name="b" namespace="{$npdoc_ns}"><xsl:text>&#9;&#9;&#9;&#9;&#9;</xsl:text><xsl:value-of select="./tr/td[@class = 'sm']"/></xsl:element>
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
       							<xsl:when test="./@class = 'lag'"><xsl:value-of select="." /></xsl:when>
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
		<xsl:apply-templates/>
	</xsl:template>
	


</xsl:stylesheet>

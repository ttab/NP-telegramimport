<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
	version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"	
	xmlns:xhtml="http://www.w3.org/1999/xhtml"
	 exclude-result-prefixes="#default xhtml xsl">
	
	<!-- XSLT som visar hur man kan konvertera TTNewsMLG2-version 2.20 till xml-filer för import som telegram i Newspilot. 
	       Telegramimporten sker i två delar där metadata hanteras av ett filter och själva innehållet av ett annat.
	       När det här filtret gjordes fanns det ingen funktionalitet för att markera att ett telegram ersätter ett tidigare telegram.
	       En del av det här kan behöva justeras för andra uppsättningar av Newspilot. Alla typer och id-nummer kanske inte matchar.
	       
	       (Den här behöver kompletteras med hantering av sportresultat och tabeller.)
	       
	       Johan Lindgren / TT / 2015-06-08
	-->

	<xsl:variable name="npdoc_ns">http://www.infomaker.se/npdoc/2.1</xsl:variable> <!-- NP vill ha namespace på alla element. -->
	
	<xsl:strip-space elements="*"/>
	
	<xsl:output encoding="UTF-8" indent="yes" method="xml" media-type="text/xml" omit-xml-declaration="no" version="1.0"/>

       <!-- Grund-template -->
	<xsl:template match="/">
		<xsl:element name="nptgr"> 
			
			<xsl:for-each select="//contentSet/inlineXML"> <!-- Gå igenom alla texter i filen -->
						
						<xsl:apply-templates select="./html/body"/> <!-- Utgå från body i html -->
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
	
	<xsl:template match="p">
		<xsl:element name="p" namespace="{$npdoc_ns}"><xsl:value-of select="normalize-space(.)"/></xsl:element>
	</xsl:template>
	
	<xsl:template match="blockquote">
		<xsl:element name="subheadline2" namespace="{$npdoc_ns}"><xsl:attribute name="customname"><xsl:text>Citat</xsl:text></xsl:attribute><xsl:text>&#x2013; </xsl:text><xsl:value-of select="normalize-space(.)"/></xsl:element>
	</xsl:template>

	<xsl:template match="div[@class = 'bodytext']"><xsl:apply-templates/></xsl:template>
	
	<xsl:template match="div[@class = 'byline']">
		<xsl:element name="p" namespace="{$npdoc_ns}"><xsl:value-of select="normalize-space(.)"/></xsl:element>
	</xsl:template>
	
	<xsl:template match="h2">
		<xsl:element name="subheadline1" namespace="{$npdoc_ns}"><xsl:value-of select="normalize-space(.)"/></xsl:element>
	</xsl:template>
	
	<xsl:template match="figure">
		<xsl:element name="p" namespace="{$npdoc_ns}"><xsl:value-of select="normalize-space(figcaption)"/></xsl:element>
		<xsl:element name="p" namespace="{$npdoc_ns}"><xsl:value-of select="normalize-space(div[@class = 'byline'])"/></xsl:element>
		<xsl:element name="p" namespace="{$npdoc_ns}"><xsl:element name="a" namespace="{$npdoc_ns}"><xsl:attribute name="href"><xsl:value-of select="normalize-space(img/@src)"/></xsl:attribute><xsl:value-of select="normalize-space(img/@src)"/></xsl:element></xsl:element>
	</xsl:template>
	
	<xsl:template match="table">
		
		<xsl:for-each select="tr"><xsl:element name="subheadline4" namespace="{$npdoc_ns}"><xsl:attribute name="customName">Tabell</xsl:attribute></xsl:element><xsl:for-each select="td"><xsl:if test=". != ''"><xsl:text>&#9;</xsl:text><xsl:value-of select="."/></xsl:if></xsl:for-each></xsl:for-each>
		
	</xsl:template>
	
	<xsl:template match="ul">
		<xsl:for-each select="li"><xsl:element name="subheadline5" namespace="{$npdoc_ns}"><xsl:attribute name="customName">Lista</xsl:attribute><xsl:value-of select="."/></xsl:element></xsl:for-each>
	</xsl:template>
	
	


</xsl:stylesheet>

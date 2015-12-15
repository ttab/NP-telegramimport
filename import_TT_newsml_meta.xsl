<?xml version="1.0" encoding="UTF-8" standalone="yes" ?>
<xsl:stylesheet 	version="1.0"	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	
	<!-- XSLT som visar hur man kan konvertera TTNewsMLG2-version 2.20 till xml-filer för import som telegram i Newspilot. 
	       Telegramimporten sker i två delar där metadata hanteras av ett filter och själva innehållet av ett annat.
	       När det här filtret gjordes fanns det ingen funktionalitet för att markera att ett telegram ersätter ett tidigare telegram.
	       En del av det här kan behöva justeras för andra uppsättningar av Newspilot. Alla typer och id-nummer kanske inte matchar.
	       
	       Johan Lindgren / TT / 2015-06-08
	       
	       Tog bort direktlänken för att Skicka artikel eftersom den kräver ytterligare utveckling av TT. JL 20150828.
	       Komplettering för att klara contentMetaExtPropertys båda varianter. JL 2015-11-04
	       JL 2012-12-04 Lade till så ersatta texter markeras
	-->
	
	<xsl:output method="xml" indent="yes" encoding="UTF-8" standalone="yes"/>
	
	<!-- Grund-template -->
	<xsl:template match="/">
		
		<xsl:variable name="mainuri" select="newsMessage/itemSet/packageItem/groupSet/group[@role = 'group:main']/itemRef/@residref"/> <!-- Börja med att hämta den id-referens som pekar ut main newsitem i paketet. NewsML-filen har en package item även om det bara är en ensam text. -->
		
		<xsl:variable name="externt_id">
			<xsl:choose>
				<xsl:when test="normalize-space(newsMessage/itemSet/newsItem[@guid = $mainuri]/contentMeta/contentMetaExtProperty[@type = 'ttext:originaltransmissionreference']) != ''"><xsl:value-of select="normalize-space(newsMessage/itemSet/newsItem[@guid = $mainuri]/contentMeta/contentMetaExtProperty[@type = 'ttext:originaltransmissionreference'])"/></xsl:when>
				<xsl:otherwise><xsl:value-of select="normalize-space(newsMessage/itemSet/newsItem[@guid = $mainuri]/contentMeta/contentMetaExtProperty[@type = 'ttext:originaltransmissionreference']/@literal)"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable> <!-- Hämta TT:s id på artikeln -->

		<xsl:variable name="prodiduri"><xsl:value-of select="normalize-space(newsMessage/itemSet/newsItem[@guid = $mainuri]/@guid)"/></xsl:variable> <!-- Hämtar TT:s kompletta guid till nyhetsobjektet. Inte att blanda ihop med TT:s begrepp PRODUKT-ID som anger saker som INR och UTR. -->

		<xsl:variable name="artikeluri" select="substring-after($mainuri,'/media/text/')"/>  <!-- Kopiera själva "filnamnet" -->

		<xsl:variable name="namnet"><xsl:value-of select="normalize-space(newsMessage/itemSet/newsItem[@guid = $mainuri]/contentMeta/headline)"/></xsl:variable> <!-- Rubriken på nyhetsobjektet används som namn i NP. -->

		<xsl:variable name="edstat">
			<xsl:choose>
				<xsl:when test="normalize-space(newsMessage/itemSet/newsItem[@guid = $mainuri]/contentMeta/contentMetaExtProperty[@type = 'ttext:profile']) != ''"><xsl:value-of select="normalize-space(newsMessage/itemSet/newsItem[@guid = $mainuri]/contentMeta/contentMetaExtProperty[@type = 'ttext:profile'])"/></xsl:when>
				<xsl:otherwise><xsl:value-of select="normalize-space(newsMessage/itemSet/newsItem[@guid = $mainuri]/contentMeta/contentMetaExtProperty[@type = 'ttext:profile']/@literal)"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable> <!-- Ta in vilken status det är. Kan vara PUBL, DATA eller INFO -->

		<xsl:variable name="kategorier"> <!-- Samla ihop alla ämneskategorier som är satta på nyhetsbojektet. Dessa läggs som förkortningar med : mellan för att användas för urval i telegramfliken -->
			<xsl:if test="newsMessage/itemSet/newsItem[@guid = $mainuri]/contentMeta/subject[@type = 'cpnat:abstract']">
				<xsl:call-template name="SamlaSubref"><xsl:with-param name="mainuri" select="$mainuri"/></xsl:call-template>
			</xsl:if>
		</xsl:variable> 
		
		<xsl:variable name="source_label"><xsl:value-of select="normalize-space(newsMessage/itemSet/newsItem[@guid = $mainuri]/contentMeta/subject[@type = 'tt:product']/name)"/></xsl:variable> <!-- TT:s produktnamn -->
		
		<xsl:variable name="infosource"> <!-- Källan till materialet i nyhetsobjektet. TT används som default om de andra varianterna inte ger något resultat. -->
			<xsl:choose>
				<xsl:when test="newsMessage/itemSet/packageItem/itemMeta/provider"><xsl:value-of select="substring-after(newsMessage/itemSet/packageItem/itemMeta/provider/@qcode,'nprov:')"/></xsl:when>
				<xsl:when test="newsMessage/itemSet/newsItem[@guid = $mainuri]/contentMeta/infoSource/name"><xsl:value-of select="newsMessage/itemSet/newsItem[@guid = $mainuri]/contentMeta/infoSource/name"/></xsl:when>
				<xsl:when test="newsMessage/itemSet/newsItem[@guid = $mainuri]/contentMeta/infoSource/@literal"><xsl:value-of select="newsMessage/itemSet/newsItem[@guid = $mainuri]/contentMeta/infoSource/@literal"/></xsl:when>
				<xsl:otherwise>TT</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:variable name="produktkoder"> <!-- Ta in produkt-kod(erna) för användning i uppsättning av tkod och sektion -->
			<xsl:text>:</xsl:text>
			<xsl:for-each select="newsMessage/itemSet/newsItem[@guid = $mainuri]/contentMeta/subject[@type = 'tt:product']">
				<xsl:value-of select="concat(./@literal,':')"/>
			</xsl:for-each>
		</xsl:variable>
		
		<xsl:variable name="tkod">
			<xsl:choose>
				<xsl:when test="contains($produktkoder,':FT')">FEA</xsl:when>
				<xsl:when test="contains($produktkoder,':TTINR:')">INR</xsl:when>
				<xsl:when test="contains($produktkoder,':TTUTR:')">UTR</xsl:when>
				<xsl:when test="contains($produktkoder,':TTSPT:')">SPT</xsl:when>
				<xsl:when test="contains($produktkoder,':TTSPTPL:')">SPT</xsl:when>
				<xsl:when test="contains($produktkoder,':TTSTJ:')">SPT</xsl:when>
				<xsl:when test="contains($produktkoder,':TTSPR:')">SPR</xsl:when>
				<xsl:when test="contains($produktkoder,':REDINFSPT:')">SPT</xsl:when>
				<xsl:when test="contains($produktkoder,':TTTBL:')">TBL</xsl:when>
				<xsl:when test="contains($produktkoder,':TTTTL:')">TTL</xsl:when>
				<xsl:when test="contains($produktkoder,':TTEKO:')">EKO</xsl:when>
				<xsl:when test="contains($produktkoder,':TTKUL')">NOJ</xsl:when>
				<xsl:when test="contains($produktkoder,':TTNOJ')">NOJ</xsl:when>
				<xsl:when test="contains($produktkoder,':TTREC')">NOJ</xsl:when>
				<xsl:when test="contains($produktkoder,':TTNOJKULN')">NOJ</xsl:when>
				<xsl:otherwise>INR</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:variable name="sektion">
			<xsl:choose>
				<xsl:when test="contains($produktkoder,':FT')">Feature</xsl:when>
				<xsl:when test="contains($produktkoder,':TTINR:')">Inrikes</xsl:when>
				<xsl:when test="contains($produktkoder,':TTUTR:')">Utrikes</xsl:when>
				<xsl:when test="contains($produktkoder,':TTSPT:')">Sport</xsl:when>
				<xsl:when test="contains($produktkoder,':TTSPTPL:')">Sport</xsl:when>
				<xsl:when test="contains($produktkoder,':TTSTJ:')">Sport</xsl:when>
				<xsl:when test="contains($produktkoder,':TTSPR:')">Sport</xsl:when>
				<xsl:when test="contains($produktkoder,':REDINFSPT:')">Sport</xsl:when>
				<xsl:when test="contains($produktkoder,':TTTBL:')">Sport</xsl:when>
				<xsl:when test="contains($produktkoder,':TTTTL:')">Sport</xsl:when>
				<xsl:when test="contains($produktkoder,':TTEKO:')">Ekonomi</xsl:when>
				<xsl:when test="contains($produktkoder,':TTKUL')">Nöje och Kultur</xsl:when>
				<xsl:when test="contains($produktkoder,':TTNOJ')">Nöje och Kultur</xsl:when>
				<xsl:when test="contains($produktkoder,':TTREC')">Nöje och Kultur</xsl:when>
				<xsl:when test="contains($produktkoder,':TTNOJKULN')">Nöje och Kultur</xsl:when>
				<xsl:otherwise>Inrikes</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:variable name="notering"><xsl:value-of select="newsMessage/itemSet/newsItem[@guid = $mainuri]/itemMeta/edNote"/></xsl:variable>  <!-- Info från TT till kunderna -->
		
		<xsl:variable name="prio"><xsl:value-of select="newsMessage/itemSet/newsItem[@guid = $mainuri]/contentMeta/urgency"/></xsl:variable> <!-- Prio på själva nyheten -->

		<xsl:variable name="slugg"><xsl:value-of select="newsMessage/itemSet/newsItem[@guid = $mainuri]/contentMeta/slugline"/></xsl:variable>  <!-- TT:s slugg -->
           
		<xsl:variable name="webbprio">
			<xsl:choose>
				<xsl:when test="normalize-space(newsMessage/itemSet/newsItem[@guid = $mainuri]/contentMeta/contentMetaExtProperty[@type = 'ttext:webprio']) != ''"><xsl:value-of select="normalize-space(newsMessage/itemSet/newsItem[@guid = $mainuri]/contentMeta/contentMetaExtProperty[@type = 'ttext:webprio'])"/></xsl:when>
				<xsl:otherwise><xsl:value-of select="normalize-space(newsMessage/itemSet/newsItem[@guid = $mainuri]/contentMeta/contentMetaExtProperty[@type = 'ttext:webprio']/@literal)"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable> <!-- Om nyheten ingår i webbtjänsten har den en speciell webb-prio -->
           
		<xsl:variable name="embargo"><xsl:value-of select="newsMessage/itemSet/packageItem/itemMeta/embargoed"/></xsl:variable>  <!-- Eventuell embargo-tid -->

		<xsl:variable name="personer"><xsl:for-each select="newsMessage/itemSet/newsItem[@guid = $mainuri]/contentMeta/subject[@type = 'cpnat:person']"><xsl:value-of select="./name"/><xsl:if test="position() != last()">,</xsl:if></xsl:for-each></xsl:variable>           
		<xsl:variable name="organisationer"><xsl:for-each select="newsMessage/itemSet/newsItem[@guid = $mainuri]/contentMeta/subject[@type = 'cpnat:organisation']"><xsl:value-of select="./name"/><xsl:if test="position() != last()">,</xsl:if></xsl:for-each></xsl:variable>           
		<xsl:variable name="platser"><xsl:for-each select="newsMessage/itemSet/newsItem[@guid = $mainuri]/contentMeta/subject[@type = 'cpnat:place']"><xsl:value-of select="./name"/><xsl:if test="position() != last()">,</xsl:if></xsl:for-each></xsl:variable>           
		<xsl:variable name="objekt"><xsl:for-each select="newsMessage/itemSet/newsItem[@guid = $mainuri]/contentMeta/subject[@type = 'cpnat:object']"><xsl:value-of select="./name"/><xsl:if test="position() != last()">,</xsl:if></xsl:for-each></xsl:variable>           
		
		<xsl:variable name="datetimesent"><xsl:value-of select="normalize-space(substring-before(newsMessage/itemSet/newsItem[@guid = $mainuri]/itemMeta/versionCreated,'+'))"/></xsl:variable> <!-- Datum och tid då nyheten publicerades -->

               <!-- Här börjar vi bygga output för NewsPilot -->
		<metadata>
			<external_id><xsl:value-of select="$externt_id"/></external_id>  <!-- I NP-importen heter fältet external_id och ska visas som Externt id i Telegramfliken. Men just nu används prod_id till båda fälten.  -->
			<prod_id><xsl:value-of select="$prodiduri"/></prod_id> <!-- I NP-importen heter fältet prod_id och ska visas som Produkt-ID i Telegramfliken. Men just nu används prod_id till båda fälten.  -->
			<!-- label <label>Label: </label>-->
			<name><xsl:value-of select="$namnet"/></name> <!-- I NP-importen heter fältet name och visas som Namn i telegramfliken. -->
			<edstat><xsl:value-of select="$edstat"/></edstat><!-- I NP-importen heter fältet edstat och visas som Editionsstatus i telegramfliken-->
			<category><xsl:value-of select="$kategorier"/></category>   <!-- I NP-importen heter fältet category och är kolon-separerad lista av förkortningar. Visas som Kategorier i telegramfliken och kan användas för urval -->
			<source_label></source_label>   <!-- I NP-importen heter fältet source_label  och det ska visas som Etikett. Men just nu används source både till Källa och Etikett.-->
			<source><xsl:value-of select="$infosource"/></source>  <!-- I NP-importen heter fältet source_label  och det visas som Källa. Men just nu används source både till Källa och Etikett.-->
			<destination>ALL</destination>  <!-- Destination är ett äldre begrepp som inte längre används. Hårdkodat till ALL för visningen i Telegramfliken. -->
			<!--<message></message>  fältet message visas som  Meddelande. Vi har valt att använda note/Notering istället eftersom det ger en markering i telegrammets ikon vid import. -->
			<prod><xsl:value-of select="$tkod"/></prod> <!-- I NP-importen heter fältet prod och visas som Produkt i telegramfliken. -->
			<note><xsl:value-of select="$notering"/></note><!-- I NP-importen heter fältet note och visas som Notering i telegramfliken. Om den har innehåll så blir det en liten prick på ikonen för telegrammet. Noteringen ska också visas om man gör artikel av telegrammet.-->
			<!-- prod_action -->
			<prio><xsl:value-of select="$prio"/></prio>  <!-- I np-importen heter fältet prio och visas som Prioritet i telegramfliken -->
			<!--<xsl:if test="newsItem/itemMeta/link">  Referenser fungerar inte vid telegramimport av xml-baserat data. Det ska fixas i kommande uppgradering av Newspilot.
			<ref_action>02</ref_action>
				<xsl:variable name="refguid"><xsl:value-of select="substring-after(newsItem/itemMeta/link/@href,'text/')"/></xsl:variable>
				<ref_id><xsl:value-of select="concat('urn:newsml:tt.se:20',substring-before($refguid,'-'),':',$refguid)"/></ref_id>
			</xsl:if>-->
                    <!-- ref_action -->
			<!-- ref_id -->
			<xsl:if test="newsMessage/itemSet/newsItem[@guid = $mainuri]/itemMeta/link[@rel ='irel:previousVersion']">
				<ref>
					<xsl:for-each select="newsMessage/itemSet/newsItem[@guid = $mainuri]/itemMeta/link[@rel ='irel:previousVersion']">
						<external_system_id>41</external_system_id>
						<external_id><xsl:value-of select="./@href"/></external_id>
					</xsl:for-each>
				</ref>
			</xsl:if> 
			<slug><xsl:value-of select="$slugg"/></slug> <!-- I np-importen heter fältet slug och visas som Slugg i telegramfliken -->
			<!-- custom 1-10 -->
			<custom_1><xsl:value-of select="$sektion"/></custom_1>   <!-- Fältet custom_1 i np-importen innehåller vilkan avdelning det gäller och visas som Avdelning i telegramfliken -->
			<custom_2><xsl:value-of select="$produktkoder"/></custom_2> <!-- I fältet custom_2 ligger TT:s nya produktkoder, kolonseparerade. Det kan visas som Eget-2 i telegramfliken -->
			<custom_3><xsl:value-of select="$webbprio"/></custom_3> <!-- Eventuell webb-prio läggs i fältet custom_3 som kan visas som Eget-3 i telegramfliken -->
			<custom_4><xsl:value-of select="$embargo"/></custom_4> <!-- Om ett embargo är angivet så sätts det i fältet custom_4 i NP-importen -->
			<custom_5></custom_5>
			<custom_6></custom_6>
			<custom_7><xsl:value-of select="$personer"/></custom_7> <!-- De personer som taggats i texten. -->
			<custom_8><xsl:value-of select="$organisationer"/></custom_8> <!-- De organisationer som taggats i texten -->
			<custom_9><xsl:value-of select="$platser"/></custom_9> <!-- De platser som taggats i texten. -->
			<custom_10><xsl:value-of select="$objekt"/></custom_10> <!-- De objekt som taggats i texten. -->
			<!-- userinfo -->
			<xsl:if test="newsMessage/itemSet/newsItem[@guid = $mainuri]/contentSet/inlineXML/html/body/article/section/div[@class = 'byline']"> <!-- Om vi har någon byline under texten -->
				<userinfo>
					<xsl:for-each select="newsMessage/itemSet/newsItem[@guid = $mainuri]/contentSet/inlineXML/html/body/article/section/div[@class = 'byline']"> <!-- Visas i telegramfliken under Byline -->
						<userdata>
							<firstname><xsl:value-of select="substring-before(.,' ')"/></firstname>
							<lastname><xsl:value-of select="substring-after(.,' ')"/></lastname>
						</userdata>
					</xsl:for-each>
				</userinfo>
			</xsl:if>
			<!-- links -->
                    <links>
                    	<link><a><xsl:attribute name="href"><xsl:value-of select="newsMessage/itemSet/newsItem[@guid = $mainuri]/@guid"/></xsl:attribute><xsl:text>TT:s kundwebb </xsl:text></a></link>  <!-- Sätt ihop en länk till tt:s kundwebb och denna nyhet. Visas i telegramfliken under Länkar -->
                    	<link><a><xsl:attribute name="href"><xsl:value-of select="concat(newsMessage/itemSet/newsItem[@guid = $mainuri]/@guid,'?channel=user:internkoll:artikelftp&amp;agr=41329&amp;ak=4728d90f-cef8-4349-b603-2e20803df607')"/></xsl:attribute><xsl:text> Hämtning</xsl:text></a></link>  <!-- Sätt ihop en länk till tt:s kundwebb och denna nyhet. Visas i telegramfliken under Länkar -->
                    </links>
			<sent pattern="yyyy-MM-dd'T'HH:mm:ss" locale="sv"><xsl:value-of select="$datetimesent"/></sent> <!-- I NP-importen heter fältet sent och visas i telegramfliken som Skickat. Fältet Mottaget sätts automatiskt av NP-importen -->
		</metadata>
	</xsl:template>
	
	
	
	<!-- Template för att plocka ut rätt ämneskategorier -->
	
	<xsl:template name="SamlaSubref">
		<xsl:param name="mainuri"/>
		<xsl:text>:</xsl:text>
		<xsl:for-each select="newsMessage/itemSet/newsItem[@guid = $mainuri]/contentMeta/subject[@type = 'cpnat:abstract']">
			<xsl:choose>
				<xsl:when test="./@qcode = 'medtop:01000000'">KLT:</xsl:when>
				<xsl:when test="./@qcode = 'medtop:20000005'">FLM:</xsl:when>
				<xsl:when test="./@qcode = 'medtop:20000011'">MDE:</xsl:when>
				<xsl:when test="./@qcode = 'medtop:20000013'">MUS:</xsl:when>
				<xsl:when test="./@qcode = 'medtop:20000029'">TEA:</xsl:when>
				<xsl:when test="./@qcode = 'medtop:20000051'">TEV:</xsl:when>
				<xsl:when test="./@qcode = 'medtop:02000000'">LAG:</xsl:when>
				<xsl:when test="./@qcode = 'medtop:03000000'">OLY:</xsl:when>
				<xsl:when test="./@qcode = 'medtop:04000000'">EKO:</xsl:when>
				<xsl:when test="./@qcode = 'medtop:20000210'">AGR:</xsl:when>
				<xsl:when test="./@qcode = 'medtop:20000337'">TRA:</xsl:when>
				<xsl:when test="./@qcode = 'medtop:20000243'">KON:</xsl:when>
				<xsl:when test="./@qcode = 'medtop:20000285'">PEK:</xsl:when>
				<xsl:when test="./@qcode = 'medtop:20000304'">MDI:</xsl:when>
				<xsl:when test="./@qcode = 'medtop:05000000'">UTB:</xsl:when>
				<xsl:when test="./@qcode = 'medtop:06000000'">MLJ:</xsl:when>
				<xsl:when test="./@qcode = 'medtop:07000000'">MED:</xsl:when>
				<xsl:when test="./@qcode = 'medtop:08000000'">HUM:</xsl:when>
				<xsl:when test="./@qcode = 'medtop:20000500'">DJR:</xsl:when>
				<xsl:when test="./@qcode = 'medtop:20000505'">CEL:</xsl:when>
				<xsl:when test="./@qcode = 'medtop:20000506'">ROY:</xsl:when>
				<xsl:when test="./@qcode = 'medtop:09000000'">ARB:</xsl:when>
				<xsl:when test="./@qcode = 'medtop:10000000'">FRI:</xsl:when>
				<xsl:when test="./@qcode = 'medtop:20000538'">FRT:</xsl:when>
				<xsl:when test="./@qcode = 'medtop:20000540'">KRS:</xsl:when>
				<xsl:when test="./@qcode = 'medtop:20000550'">HBY:</xsl:when>
				<xsl:when test="./@qcode = 'medtop:20000563'">RES:</xsl:when>
				<xsl:when test="./@qcode = 'medtop:20000566'">MTR:</xsl:when>
				<xsl:when test="./@qcode = 'medtop:20000568'">MAT:</xsl:when>
				<xsl:when test="./@qcode = 'medtop:20000570'">HEM:</xsl:when>
				<xsl:when test="./@qcode = 'medtop:11000000'">POL:</xsl:when>
				<xsl:when test="./@qcode = 'medtop:12000000'">REL:</xsl:when>
				<xsl:when test="./@qcode = 'medtop:13000000'">TKN:</xsl:when>
				<xsl:when test="./@qcode = 'medtop:20000746'">GEO:</xsl:when>
				<xsl:when test="./@qcode = 'medtop:14000000'">SOC:</xsl:when>
				<xsl:when test="./@qcode = 'medtop:15000000'">SPT:</xsl:when>
				<xsl:when test="./@qcode = 'medtop:16000000'">ORO:</xsl:when>
				<xsl:when test="./@qcode = 'medtop:17000000'">VDR:</xsl:when>
				<!--<xsl:when test="./@qcode = 'medtop:'">:</xsl:when>
				<xsl:when test="./@qcode = 'medtop:'">:</xsl:when>-->
			</xsl:choose>
		</xsl:for-each>
	
<!--					<xsl:when test="./@name = 'Flygsport'">&lt;SUBREF ID="2:12"&gt;TT:15001000:SPT&lt;/SUBREF&gt;&#10;</xsl:when>
					<xsl:when test="./@name = 'Alpint'">&lt;SUBREF ID="2:12"&gt;TT:15002000:SPT&lt;/SUBREF&gt;&#10;</xsl:when>
					<xsl:when test="./@name = 'Amerikansk fotboll'">&lt;SUBREF ID="2:12"&gt;TT:15003000:SPT&lt;/SUBREF&gt;&#10;</xsl:when>
					<xsl:when test="./@name = 'Bågskytte'">&lt;SUBREF ID="2:12"&gt;TT:15004000:SPT&lt;/SUBREF&gt;&#10;</xsl:when>
					<xsl:when test="./@name = 'Friidrott'">&lt;SUBREF ID="2:12"&gt;TT:15005000:SPT&lt;/SUBREF&gt;&#10;</xsl:when>
					<xsl:when test="./@name = 'Badminton'">&lt;SUBREF ID="2:12"&gt;TT:15006000:SPT&lt;/SUBREF&gt;&#10;</xsl:when>
					<xsl:when test="./@name = 'Baseboll'">&lt;SUBREF ID="2:12"&gt;TT:15007000:SPT&lt;/SUBREF&gt;&#10;</xsl:when>
					<xsl:when test="./@name = 'Basket'">&lt;SUBREF ID="2:12"&gt;TT:15008000:SPT&lt;/SUBREF&gt;&#10;</xsl:when>
					<xsl:when test="./@name = 'Skidskytte'">&lt;SUBREF ID="2:12"&gt;TT:15009000:SPT&lt;/SUBREF&gt;&#10;</xsl:when>
					<xsl:when test="./@name = 'Biljard'">&lt;SUBREF ID="2:12"&gt;TT:15010000:SPT&lt;/SUBREF&gt;&#10;</xsl:when>
					<xsl:when test="./@name = 'Bob'">&lt;SUBREF ID="2:12"&gt;TT:15011000:SPT&lt;/SUBREF&gt;&#10;</xsl:when>
					<xsl:when test="./@name = 'Bowling'">&lt;SUBREF ID="2:12"&gt;TT:15012000:SPT&lt;/SUBREF&gt;&#10;</xsl:when>
					<xsl:when test="./@name = 'Boule'">&lt;SUBREF ID="2:12"&gt;TT:15013000:SPT&lt;/SUBREF&gt;&#10;</xsl:when>
					<xsl:when test="./@name = 'Boxning'">&lt;SUBREF ID="2:12"&gt;TT:15014000:SPT&lt;/SUBREF&gt;&#10;</xsl:when>
					<xsl:when test="./@name = 'Kanot'">&lt;SUBREF ID="2:12"&gt;TT:15015000:SPT&lt;/SUBREF&gt;&#10;</xsl:when>
					<xsl:when test="./@name = 'Klättring'">&lt;SUBREF ID="2:12"&gt;TT:15016000:SPT&lt;/SUBREF&gt;&#10;</xsl:when>
					<xsl:when test="./@name = 'Curling'">&lt;SUBREF ID="2:12"&gt;TT:15018000:SPT&lt;/SUBREF&gt;&#10;</xsl:when>
					<xsl:when test="./@name = 'Cykel'">&lt;SUBREF ID="2:12"&gt;TT:15019000:SPT&lt;/SUBREF&gt;&#10;</xsl:when>
					<xsl:when test="./@name = 'Danssport'">&lt;SUBREF ID="2:12"&gt;TT:15020000:SPT&lt;/SUBREF&gt;&#10;</xsl:when>
					<xsl:when test="./@name = 'Simhopp'">&lt;SUBREF ID="2:12"&gt;TT:15021000:SPT&lt;/SUBREF&gt;&#10;</xsl:when>
					<xsl:when test="./@name = 'Ridsport'">&lt;SUBREF ID="2:12"&gt;TT:15022000:SPT&lt;/SUBREF&gt;&#10;</xsl:when>
					<xsl:when test="./@name = 'Fäktning'">&lt;SUBREF ID="2:12"&gt;TT:15023000:SPT&lt;/SUBREF&gt;&#10;</xsl:when>
					<xsl:when test="./@name = 'Landhockey'">&lt;SUBREF ID="2:12"&gt;TT:15024000:SPT&lt;/SUBREF&gt;&#10;</xsl:when>
					<xsl:when test="./@name = 'Konståkning'">&lt;SUBREF ID="2:12"&gt;TT:15025000:SPT&lt;/SUBREF&gt;&#10;</xsl:when>
					<xsl:when test="./@name = 'Freestyle'">&lt;SUBREF ID="2:12"&gt;TT:15026000:SPT&lt;/SUBREF&gt;&#10;</xsl:when>
					<xsl:when test="./@name = 'Golf'">&lt;SUBREF ID="2:12"&gt;TT:15027000:SPT&lt;/SUBREF&gt;&#10;</xsl:when>
					<xsl:when test="./@name = 'Gymnastik'">&lt;SUBREF ID="2:12"&gt;TT:15028000:SPT&lt;/SUBREF&gt;&#10;</xsl:when>
					<xsl:when test="./@name = 'Handboll'">&lt;SUBREF ID="2:12"&gt;TT:15029000:SPT&lt;/SUBREF&gt;&#10;</xsl:when>
					<xsl:when test="./@name = 'Trav'">&lt;SUBREF ID="2:12"&gt;TT:15030000:SPT&lt;/SUBREF&gt;&#10;</xsl:when>
					<xsl:when test="./@name = 'Ishockey'">&lt;SUBREF ID="2:12"&gt;TT:15031000:SPT&lt;/SUBREF&gt;&#10;</xsl:when>
					<xsl:when test="./@name = 'Judo'">&lt;SUBREF ID="2:12"&gt;TT:15033000:SPT&lt;/SUBREF&gt;&#10;</xsl:when>
					<xsl:when test="./@name = 'Rodel'">&lt;SUBREF ID="2:12"&gt;TT:15036000:SPT&lt;/SUBREF&gt;&#10;</xsl:when>
					<xsl:when test="./@name = 'Modern femkamp'">&lt;SUBREF ID="2:12"&gt;TT:15038000:SPT&lt;/SUBREF&gt;&#10;</xsl:when>
					<xsl:when test="./@name = 'Bilsport'">&lt;SUBREF ID="2:12"&gt;TT:15040000:SPT&lt;/SUBREF&gt;&#10;</xsl:when>
					<xsl:when test="./@name = 'MC sport'">&lt;SUBREF ID="2:12"&gt;TT:15041000:SPT&lt;/SUBREF&gt;&#10;</xsl:when>
					<xsl:when test="./@name = 'Skidor'">&lt;SUBREF ID="2:12"&gt;TT:15043000:SPT&lt;/SUBREF&gt;&#10;</xsl:when>
					<xsl:when test="./@name = 'Orientering'">&lt;SUBREF ID="2:12"&gt;TT:15044000:SPT&lt;/SUBREF&gt;&#10;</xsl:when>
					<xsl:when test="./@name = 'Båtsport'">&lt;SUBREF ID="2:12"&gt;TT:15046000:SPT&lt;/SUBREF&gt;&#10;</xsl:when>
					<xsl:when test="./@name = 'Rodd'">&lt;SUBREF ID="2:12"&gt;TT:15047000:SPT&lt;/SUBREF&gt;&#10;</xsl:when>
					<xsl:when test="./@name = 'Rugby'">&lt;SUBREF ID="2:12"&gt;TT:15048000:SPT&lt;/SUBREF&gt;&#10;</xsl:when>
					<xsl:when test="./@name = 'Segling'">&lt;SUBREF ID="2:12"&gt;TT:15049000:SPT&lt;/SUBREF&gt;&#10;</xsl:when>
					<xsl:when test="./@name = 'Skytte'">&lt;SUBREF ID="2:12"&gt;TT:15050000:SPT&lt;/SUBREF&gt;&#10;</xsl:when>
					<xsl:when test="./@name = 'Backhoppning'">&lt;SUBREF ID="2:12"&gt;TT:15051000:SPT&lt;/SUBREF&gt;&#10;</xsl:when>
					<xsl:when test="./@name = 'Snowboard'">&lt;SUBREF ID="2:12"&gt;TT:15052000:SPT&lt;/SUBREF&gt;&#10;</xsl:when>
					<xsl:when test="./@name = 'Fotboll'">&lt;SUBREF ID="2:12"&gt;TT:15054000:SPT&lt;/SUBREF&gt;&#10;</xsl:when>
					<xsl:when test="./@name = 'Softboll'">&lt;SUBREF ID="2:12"&gt;TT:15055000:SPT&lt;/SUBREF&gt;&#10;</xsl:when>
					<xsl:when test="./@name = 'Skridsko'">&lt;SUBREF ID="2:12"&gt;TT:15056000:SPT&lt;/SUBREF&gt;&#10;</xsl:when>
					<xsl:when test="./@name = 'Speedway'">&lt;SUBREF ID="2:12"&gt;TT:15057000:SPT&lt;/SUBREF&gt;&#10;</xsl:when>
					<xsl:when test="./@name = 'Squash'">&lt;SUBREF ID="2:12"&gt;TT:15059000:SPT&lt;/SUBREF&gt;&#10;</xsl:when>
					<xsl:when test="./@name = 'Simning'">&lt;SUBREF ID="2:12"&gt;TT:15062000:SPT&lt;/SUBREF&gt;&#10;</xsl:when>
					<xsl:when test="./@name = 'Bordtennis'">&lt;SUBREF ID="2:12"&gt;TT:15063000:SPT&lt;/SUBREF&gt;&#10;</xsl:when>
					<xsl:when test="./@name = 'Taekwondo'">&lt;SUBREF ID="2:12"&gt;TT:15064000:SPT&lt;/SUBREF&gt;&#10;</xsl:when>
					<xsl:when test="./@name = 'Tennis'">&lt;SUBREF ID="2:12"&gt;TT:15065000:SPT&lt;/SUBREF&gt;&#10;</xsl:when>
					<xsl:when test="./@name = 'Triathlon'">&lt;SUBREF ID="2:12"&gt;TT:15066000:SPT&lt;/SUBREF&gt;&#10;</xsl:when>
					<xsl:when test="./@name = 'Volleyboll'">&lt;SUBREF ID="2:12"&gt;TT:15067000:SPT&lt;/SUBREF&gt;&#10;</xsl:when>
					<xsl:when test="./@name = 'Vattenpolo'">&lt;SUBREF ID="2:12"&gt;TT:15068000:SPT&lt;/SUBREF&gt;&#10;</xsl:when>
					<xsl:when test="./@name = 'Vattenskidor'">&lt;SUBREF ID="2:12"&gt;TT:15069000:SPT&lt;/SUBREF&gt;&#10;</xsl:when>
					<xsl:when test="./@name = 'Tyngdlyftning'">&lt;SUBREF ID="2:12"&gt;TT:15070000:SPT&lt;/SUBREF&gt;&#10;</xsl:when>
					<xsl:when test="./@name = 'Windsurfing'">&lt;SUBREF ID="2:12"&gt;TT:15071000:SPT&lt;/SUBREF&gt;&#10;</xsl:when>
					<xsl:when test="./@name = 'Brottning'">&lt;SUBREF ID="2:12"&gt;TT:15072000:SPT&lt;/SUBREF&gt;&#10;</xsl:when>
					<xsl:when test="./@name = 'Rodeo'">&lt;SUBREF ID="2:12"&gt;TT:15074000:SPT&lt;/SUBREF&gt;&#10;</xsl:when>
					<xsl:when test="./@name = 'Bangolf'">&lt;SUBREF ID="2:12"&gt;TT:15075000:SPT&lt;/SUBREF&gt;&#10;</xsl:when>
					<xsl:when test="./@name = 'Bandy'">&lt;SUBREF ID="2:12"&gt;TT:15076000:SPT&lt;/SUBREF&gt;&#10;</xsl:when>
					<xsl:when test="./@name = 'Frisbee'">&lt;SUBREF ID="2:12"&gt;TT:15077000:SPT&lt;/SUBREF&gt;&#10;</xsl:when>
					<xsl:when test="./@name = 'Innebandy'">&lt;SUBREF ID="2:12"&gt;TT:15078000:SPT&lt;/SUBREF&gt;&#10;</xsl:when>
					<xsl:when test="./@name = 'Casting'">&lt;SUBREF ID="2:12"&gt;TT:15079000:SPT&lt;/SUBREF&gt;&#10;</xsl:when>
					<xsl:when test="./@name = 'Dragkamp'">&lt;SUBREF ID="2:12"&gt;TT:15080000:SPT&lt;/SUBREF&gt;&#10;</xsl:when>
					<xsl:when test="./@name = 'Hundsport'">&lt;SUBREF ID="2:12"&gt;TT:15082000:SPT&lt;/SUBREF&gt;&#10;</xsl:when>
					<xsl:when test="./@name = 'Budo'">&lt;SUBREF ID="2:12"&gt;TT:15202000:SPT&lt;/SUBREF&gt;&#10;</xsl:when>
					<xsl:when test="./@name = 'Dövsport'">&lt;SUBREF ID="2:12"&gt;TT:15205000:SPT&lt;/SUBREF&gt;&#10;</xsl:when>
					<xsl:when test="./@name = 'Gång'">&lt;SUBREF ID="2:12"&gt;TT:15207000:SPT&lt;/SUBREF&gt;&#10;</xsl:when>
					<xsl:when test="./@name = 'Handikappidrott'">&lt;SUBREF ID="2:12"&gt;TT:15208000:SPT&lt;/SUBREF&gt;&#10;</xsl:when>
					<xsl:when test="./@name = 'Kanotsegling'">&lt;SUBREF ID="2:12"&gt;TT:15211000:SPT&lt;/SUBREF&gt;&#10;</xsl:when>
					<xsl:when test="./@name = 'Dyksport'">&lt;SUBREF ID="2:12"&gt;TT:15212000:SPT&lt;/SUBREF&gt;&#10;</xsl:when>
					<xsl:when test="./@name = 'Skidorientering'">&lt;SUBREF ID="2:12"&gt;TT:15213000:SPT&lt;/SUBREF&gt;&#10;</xsl:when>
					<xsl:when test="./@name = 'Styrkelyft'">&lt;SUBREF ID="2:12"&gt;TT:15214000:SPT&lt;/SUBREF&gt;&#10;</xsl:when>
					<xsl:when test="./@name = 'Trav'">&lt;SUBREF ID="2:12"&gt;TT:15215000:SPT&lt;/SUBREF&gt;&#10;</xsl:when>
					<xsl:when test="./@name = 'Varpa'">&lt;SUBREF ID="2:12"&gt;TT:15216000:SPT&lt;/SUBREF&gt;&#10;</xsl:when>
					<xsl:when test="./@name = 'Lotterier'">&lt;SUBREF ID="2:12"&gt;TT:15300000:SPT&lt;/SUBREF&gt;&#10;</xsl:when>
					<xsl:when test="./@name = 'Spel'">&lt;SUBREF ID="2:12"&gt;TT:15310000:SPT&lt;/SUBREF&gt;&#10;</xsl:when>
					<xsl:when test="./@name = 'Startlista'">&lt;SUBREF ID="2:12"&gt;TT:15320000:SPT&lt;/SUBREF&gt;&#10;</xsl:when>
					<xsl:when test="./@name = 'Tips'">&lt;SUBREF ID="2:12"&gt;TT:15330000:SPT&lt;/SUBREF&gt;&#10;</xsl:when>
-->				
	</xsl:template>
	
	
	
</xsl:stylesheet>

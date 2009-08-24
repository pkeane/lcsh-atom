<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" 
  xmlns:dcterms="http://purl.org/dc/terms/"
  xmlns:owl="http://www.w3.org/2002/07/owl#"
  xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
  xmlns:skos="http://www.w3.org/2004/02/skos/core#"
  xmlns:atom="http://www.w3.org/2005/Atom"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:media="http://search.yahoo.com/mrss/"
  xmlns:h="http://www.w3.org/1999/xhtml"
  xmlns:perl="urn:perl"
  >
  <xsl:output method="xml" indent="yes" encoding="UTF-8"/>
  <!--
  <xsl:variable name="labels" select="document('labels.xml')/labels"/>
  <xsl:key name="label-lookup" match="label" use="@id"/>
  -->


  <xsl:template match="/">
	<xsl:element name="entry" namespace="http://www.w3.org/2005/Atom">
	  <xsl:apply-templates select="rdf:Description"/>
	</xsl:element>
  </xsl:template>

  <xsl:template match="rdf:Description">
	<xsl:element name="id" namespace="http://www.w3.org/2005/Atom">
	  <xsl:value-of select="@rdf:about"/>
	</xsl:element>
	<xsl:element name="author" namespace="http://www.w3.org/2005/Atom">
	  <xsl:element name="name" namespace="http://www.w3.org/2005/Atom">Library of Congress</xsl:element>
	</xsl:element>
	<xsl:apply-templates select="skos:prefLabel"/>
	<xsl:apply-templates select="dcterms:created"/>
	<xsl:apply-templates select="dcterms:modified"/>
	<xsl:apply-templates select="skos:narrower"/>
	<xsl:apply-templates select="skos:broader"/>
	<xsl:apply-templates select="skos:related"/>
	<xsl:apply-templates select="skos:inScheme"/>
	<xsl:apply-templates select="skos:altLabel"/>
	<xsl:apply-templates select="skos:editorialNote"/>
	<xsl:apply-templates select="skos:example"/>
	<xsl:apply-templates select="skos:changeNote"/>
	<xsl:apply-templates select="skos:scopeNote"/>
	<xsl:apply-templates select="skos:closeMatch"/>
	<xsl:apply-templates select="dcterms:source"/>
	<xsl:element name="content" namespace="http://www.w3.org/2005/Atom">
	  <xsl:value-of select="skos:prefLabel"/>
	</xsl:element>
  </xsl:template>

  <xsl:template match="skos:inScheme">
	<xsl:element name="link" namespace="http://www.w3.org/2005/Atom">
	  <xsl:attribute name="href"><xsl:value-of select="@rdf:resource"/></xsl:attribute>
	  <xsl:attribute name="rel">http://www.w3.org/2004/02/skos/core#inScheme</xsl:attribute>
	  <xsl:attribute name="title"><xsl:value-of select="perl:term(@rdf:resource)"/></xsl:attribute>
	</xsl:element>
  </xsl:template>

  <xsl:template match="skos:closeMatch">
	<xsl:element name="link" namespace="http://www.w3.org/2005/Atom">
	  <xsl:attribute name="href"><xsl:value-of select="@rdf:resource"/></xsl:attribute>
	  <xsl:attribute name="rel">http://www.w3.org/2004/02/skos/core#closeMatch</xsl:attribute>
	  <xsl:attribute name="title"><xsl:value-of select="@rdf:resource"/></xsl:attribute>
	</xsl:element>
  </xsl:template>

  <xsl:template match="skos:broader">
	<xsl:element name="link" namespace="http://www.w3.org/2005/Atom">
	  <xsl:attribute name="href"><xsl:value-of select="@rdf:resource"/></xsl:attribute>
	  <xsl:attribute name="rel">http://www.w3.org/2004/02/skos/core#broader</xsl:attribute>
	  <!--
	  <xsl:attribute name="title">
		<xsl:apply-templates select="$labels">
		  <xsl:with-param name="concept-id" select="@rdf:resource"/>
		</xsl:apply-templates>
	  </xsl:attribute>
	  -->
	</xsl:element>
  </xsl:template>

  <xsl:template match="skos:narrower">
	<xsl:element name="link" namespace="http://www.w3.org/2005/Atom">
	  <xsl:attribute name="href"><xsl:value-of select="@rdf:resource"/></xsl:attribute>
	  <xsl:attribute name="rel">http://www.w3.org/2004/02/skos/core#narrower</xsl:attribute>
	  <!--
	  <xsl:attribute name="title">
		<xsl:apply-templates select="$labels">
		  <xsl:with-param name="concept-id" select="@rdf:resource"/>
		</xsl:apply-templates>
	  </xsl:attribute>
	  -->
	</xsl:element>
  </xsl:template>

  <xsl:template match="labels">
	<xsl:param name="concept-id"/>
	<xsl:value-of select="key('label-lookup', $concept-id)"/>
  </xsl:template>


  <xsl:template match="skos:related">
	<xsl:element name="link" namespace="http://www.w3.org/2005/Atom">
	  <xsl:attribute name="href"><xsl:value-of select="@rdf:resource"/></xsl:attribute>
	  <xsl:attribute name="rel">http://www.w3.org/2004/02/skos/core#related</xsl:attribute>
	  <!--
	  <xsl:attribute name="title">
		<xsl:apply-templates select="$labels">
		  <xsl:with-param name="concept-id" select="@rdf:resource"/>
		</xsl:apply-templates>
	  </xsl:attribute>
	  -->
	</xsl:element>
  </xsl:template>

  <xsl:template match="skos:prefLabel">
	<xsl:element name="title" namespace="http://www.w3.org/2005/Atom">
	  <xsl:value-of select="."/>
	</xsl:element>
	<xsl:element name="category" namespace="http://www.w3.org/2005/Atom">
	  <xsl:attribute name="term">prefLabel</xsl:attribute>
	  <xsl:attribute name="scheme">http://www.w3.org/2004/02/skos/core</xsl:attribute>
	  <xsl:attribute name="label">preferred label</xsl:attribute>
	  <xsl:value-of select="."/>
	</xsl:element>
  </xsl:template>

  <xsl:template match="dcterms:modified">
	<xsl:element name="updated" namespace="http://www.w3.org/2005/Atom">
	  <xsl:value-of select="."/>
	</xsl:element>
  </xsl:template>

  <xsl:template match="dcterms:created">
	<xsl:element name="published" namespace="http://www.w3.org/2005/Atom">
	  <xsl:value-of select="."/>
	</xsl:element>
  </xsl:template>

  <xsl:template match="dcterms:source">
	<xsl:element name="category" namespace="http://www.w3.org/2005/Atom">
	  <xsl:attribute name="term">source</xsl:attribute>
	  <xsl:attribute name="scheme">http://purl.org/dc/terms/</xsl:attribute>
	  <xsl:value-of select="."/>
	</xsl:element>
  </xsl:template>

  <xsl:template match="skos:altLabel">
	<xsl:element name="category" namespace="http://www.w3.org/2005/Atom">
	  <xsl:attribute name="term">altLabel</xsl:attribute>
	  <xsl:attribute name="scheme">http://www.w3.org/2004/02/skos/core</xsl:attribute>
	  <xsl:attribute name="label">alternate label</xsl:attribute>
	  <xsl:value-of select="."/>
	</xsl:element>
  </xsl:template>

  <xsl:template match="skos:editorialNote">
	<xsl:element name="category" namespace="http://www.w3.org/2005/Atom">
	  <xsl:attribute name="term">editorialNote</xsl:attribute>
	  <xsl:attribute name="scheme">http://www.w3.org/2004/02/skos/core</xsl:attribute>
	  <xsl:attribute name="label">editorial note</xsl:attribute>
	  <xsl:value-of select="."/>
	</xsl:element>
  </xsl:template>

  <xsl:template match="skos:changeNote">
	<xsl:element name="category" namespace="http://www.w3.org/2005/Atom">
	  <xsl:attribute name="term">changeNote</xsl:attribute>
	  <xsl:attribute name="scheme">http://www.w3.org/2004/02/skos/core</xsl:attribute>
	  <xsl:attribute name="label">change note</xsl:attribute>
	  <xsl:value-of select="."/>
	</xsl:element>
  </xsl:template>

  <xsl:template match="skos:scopeNote">
	<xsl:element name="category" namespace="http://www.w3.org/2005/Atom">
	  <xsl:attribute name="term">scopeNote</xsl:attribute>
	  <xsl:attribute name="scheme">http://www.w3.org/2004/02/skos/core</xsl:attribute>
	  <xsl:attribute name="label">scope note</xsl:attribute>
	  <xsl:value-of select="."/>
	</xsl:element>
  </xsl:template>

  <xsl:template match="skos:example">
	<xsl:element name="category" namespace="http://www.w3.org/2005/Atom">
	  <xsl:attribute name="term">example</xsl:attribute>
	  <xsl:attribute name="scheme">http://www.w3.org/2004/02/skos/core</xsl:attribute>
	  <xsl:attribute name="label">example</xsl:attribute>
	  <xsl:value-of select="."/>
	</xsl:element>
  </xsl:template>

</xsl:stylesheet>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="text" omit-xml-declaration="yes" indent="no" media-type="text/plain"/>
<xsl:template match="/">
<xsl:for-each select="list/*">
<xsl:text>nginx_dumb_requests{metric="</xsl:text><xsl:value-of select="." /><xsl:text>"} </xsl:text><xsl:value-of select="@size"/><xsl:text>&#10;</xsl:text>
</xsl:for-each>
</xsl:template></xsl:stylesheet>

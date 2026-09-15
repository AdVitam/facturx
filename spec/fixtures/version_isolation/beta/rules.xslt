<?xml version="1.0"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:svrl="http://purl.oclc.org/dsdl/svrl">
  <xsl:template match="/">
    <svrl:schematron-output>
      <svrl:successful-report id="{document('codes.xml')/codes/@rule}" flag="warning" test="true()" location="/">
        <svrl:text>Synthetic beta rule executed.</svrl:text>
      </svrl:successful-report>
    </svrl:schematron-output>
  </xsl:template>
</xsl:stylesheet>

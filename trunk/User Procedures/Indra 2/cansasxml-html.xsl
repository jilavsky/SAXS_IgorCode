<?xml version="1.0"?>

<!--
########### SVN repository information ###################
# $Date: 2009-01-12 10:19:00 -0600 (Mon, 12 Jan 2009) $
# $Author: prjemian $
# $Revision: 65 $
# $HeadURL: http://svn.smallangles.net/svn/canSAS/1dwg/trunk/IgorPro/cansasxml-html.xsl $
# $Id: cansasxml-html.xsl 65 2009-01-12 16:19:00Z prjemian $
########### SVN repository information ###################

Purpose:
	This stylesheet is used to translate cansas1d/1.0
	XML data files into a display form for viewing
	in a web browser such as Firefox or Internet Explorer.

Usage:
	xsltproc example.xsl datafile.xml > datafile.html
	(or include it as indicated at the documentation site
	http://www.smallangles.net/wgwiki/index.php/cansas1d_documentation)
-->

<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:cs="cansas1d/1.0"
	xmlns:fn="http://www.w3.org/2005/02/xpath-functions"
	>

	<xsl:template match="/">
<!-- DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd" -->
		<html>
			<head>
				<title>SAS data in canSAS 1-D format</title>
			</head>
			<body>
				<h1>SAS data in canSAS 1-D format</h1>
				<small>generated using <TT>example.xsl</TT> from canSAS</small>
				<BR />
				<table border="2">
					<tr>
						<th bgcolor="lavender">canSAS 1-D XML version:</th>
						<td><xsl:value-of select="cs:SASroot/@version" /></td>
					</tr>
					<tr>
						<th bgcolor="lavender">number of entries:</th>
						<td><xsl:value-of select="count(cs:SASroot/cs:SASentry)" /></td>
					</tr>
					<xsl:if test="count(/cs:SASroot//cs:SASentry)>1">
						<!-- if more than one SASentry, make a table of contents -->
						<xsl:for-each select="/cs:SASroot//cs:SASentry">
							<tr>
								<th bgcolor="lavender">SASentry-<xsl:value-of select="position()" /></th>
								<td>
									<a href="#SASentry-{generate-id(.)}">
										<xsl:if test="@name!=''">(<xsl:value-of select="@name" />)</xsl:if>
										<xsl:value-of select="cs:Title" />
									</a>
								</td>
								<xsl:if test="count(cs:SASdata)>1">
									<td>
										<!-- if more than one SASdata, make a local table of contents -->
										<xsl:for-each select="cs:SASdata">
											<xsl:if test="position()>1">
												<xsl:text> | </xsl:text>
											</xsl:if>
											<a href="#SASdata-{generate-id(.)}">
												<xsl:choose>
													<xsl:when test="cs:name!=''">
														<xsl:value-of select="cs:name" />
													</xsl:when>
													<xsl:when test="@name!=''">
														<xsl:value-of select="@name" />
													</xsl:when>
													<xsl:otherwise>
														SASdata<xsl:value-of select="position()" />
													</xsl:otherwise>
												</xsl:choose>
											</a>
										</xsl:for-each>
									</td>
								</xsl:if>
							</tr>
						</xsl:for-each>
					</xsl:if>
				</table>
				<xsl:apply-templates  />
				<hr />
				<small><center>$Id: cansasxml-html.xsl 65 2009-01-12 16:19:00Z prjemian $</center></small>
			</body>
		</html>
	</xsl:template>

	<xsl:template match="cs:SASroot">
		<xsl:for-each select="cs:SASentry">
			<hr />
			<br />
			<a id="#SASentry-{generate-id(.)}"  name="SASentry-{generate-id(.)}" />
			<h1>SASentry<xsl:value-of select="position()" />:<xsl:if 
				test="@name!=''">(<xsl:value-of select="@name" />)</xsl:if>
				<xsl:value-of select="cs:Title" /></h1>
			<xsl:if test="count(cs:SASdata)>1">
				<table border="2">
					<caption>SASdata contents</caption>
					<xsl:for-each select="cs:SASdata">
						<tr>
							<th>SASdata-<xsl:value-of select="position()" /></th>
							<td>
								<a href="#SASdata-{generate-id(.)}">
									<xsl:choose>
									<xsl:when test="@name!=''">
											<xsl:value-of select="@name" />
										</xsl:when>
										<xsl:otherwise>
											SASdata<xsl:value-of select="position()" />
										</xsl:otherwise>
									</xsl:choose>
								</a>
							</td>
						</tr>
					</xsl:for-each>
				</table>
			</xsl:if>
			<br />
			<table border="2">
				<tr>
					<th>SAS data</th>
					<th>Selected Metadata</th>
				</tr>
				<tr>
					<td valign="top"><xsl:apply-templates  select="cs:SASdata" /></td>
					<td valign="top">
						<table border="2">
							<tr bgcolor="lavender">
								<th>name</th>
								<th>value</th>
								<th>unit</th>
							</tr>
							<tr>
								<td>Title</td>
								<td><xsl:value-of select="cs:Title" /></td>
								<td />
							</tr>
							<tr>
								<td>Run</td>
								<td><xsl:value-of select="cs:Run" /></td>
								<td />
							</tr>
							<tr><xsl:apply-templates  select="run" /></tr>
							<xsl:apply-templates  select="cs:SASsample" />
							<xsl:apply-templates  select="cs:SASinstrument" />
							<xsl:apply-templates  select="cs:SASprocess" />
							<xsl:apply-templates  select="cs:SASnote" />
						</table>
					</td>
				</tr>
			</table>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="cs:SASdata">
		<a id="#SASdata-{generate-id(.)}"  name="SASdata-{generate-id(.)}" />
		<table border="2">
			<caption><xsl:if 
				test="@name!=''"><xsl:value-of select="@name" /></xsl:if> (<xsl:value-of 
				select="count(cs:Idata)" /> points)</caption>
			<tr bgcolor="lavender">
				<xsl:for-each select="cs:Idata[1]/*">
					<th>
						<xsl:value-of select="name()" /> 
						<xsl:if test="@unit!=''"> (<xsl:value-of select="@unit" />)</xsl:if>
					</th>
				</xsl:for-each>
			</tr>
			<xsl:for-each select="cs:Idata">
				<tr>
					<xsl:for-each select="*">
						<td><xsl:value-of select="." /></td>
					</xsl:for-each>
				</tr>
			</xsl:for-each>
		</table>
	</xsl:template>

	<xsl:template match="cs:SASsample">
		<tr>
			<td>SASsample</td>
			<td><xsl:value-of select="@name" /></td>
			<td />
		</tr>
		<xsl:for-each select="*">
			<xsl:choose>
				<xsl:when test="name()='position'">
					<xsl:apply-templates select="." />
				</xsl:when>
				<xsl:when test="name()='orientation'">
					<xsl:apply-templates select="." />
				</xsl:when>
				<xsl:otherwise>
					<tr>
						<td><xsl:value-of select="name(..)" />_<xsl:value-of select="name()" /></td>
						<td><xsl:value-of select="." /></td>
						<td><xsl:value-of select="@unit" /></td>
					</tr>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="cs:SASinstrument">
		<tr>
			<td>SASinstrument</td>
			<td><xsl:value-of select="cs:name" /></td>
			<td><xsl:value-of select="@name" /></td>
		</tr>
		<xsl:for-each select="*">
			<xsl:choose>
				<xsl:when test="name()='SASsource'"><xsl:apply-templates select="." /></xsl:when>
				<xsl:when test="name()='SAScollimation'"><xsl:apply-templates select="." /></xsl:when>
				<xsl:when test="name()='SASdetector'"><xsl:apply-templates select="." /></xsl:when>
				<xsl:when test="name()='name'" />
				<xsl:otherwise>
					<tr>
						<td><xsl:value-of select="name(..)" />_<xsl:value-of select="name()" /></td>
						<td><xsl:value-of select="." /></td>
						<td><xsl:value-of select="@unit" /></td>
					</tr>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="cs:SASsource">
		<tr>
			<td><xsl:value-of select="name()" /></td>
			<td><xsl:value-of select="@name" /></td>
			<td />
		</tr>
		<xsl:for-each select="*">
			<xsl:choose>
				<xsl:when test="name()='beam_size'"><xsl:apply-templates select="." /></xsl:when>
				<xsl:otherwise>
					<tr>
						<td><xsl:value-of select="name(..)" />_<xsl:value-of select="name()" /></td>
						<td><xsl:value-of select="." /></td>
						<td><xsl:value-of select="@unit" /></td>
					</tr>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="cs:beam_size">
		<tr>
			<td><xsl:value-of select="name(..)" />_<xsl:value-of select="name()" /></td>
			<td><xsl:value-of select="@name" /></td>
			<td />
		</tr>
		<xsl:for-each select="*">
			<tr>
				<td><xsl:value-of select="name(../..)" />_<xsl:value-of select="name(..)" />_<xsl:value-of select="name()" /></td>
				<td><xsl:value-of select="." /></td>
				<td><xsl:value-of select="@unit" /></td>
			</tr>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="cs:SAScollimation">
		<xsl:for-each select="*">
			<xsl:choose>
				<xsl:when test="name()='aperture'"><xsl:apply-templates select="." /></xsl:when>
				<xsl:otherwise>
					<tr>
						<td><xsl:value-of select="name(..)" />_<xsl:value-of select="name()" /></td>
						<td><xsl:value-of select="." /></td>
						<td><xsl:value-of select="@unit" /></td>
					</tr>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="cs:aperture">
		<tr>
			<td><xsl:value-of select="name(..)" />_<xsl:value-of select="name()" /></td>
			<td><xsl:value-of select="@name" /></td>
			<td><xsl:value-of select="@type" /></td>
		</tr>
		<xsl:for-each select="*">
			<xsl:choose>
				<xsl:when test="name()='size'"><xsl:apply-templates select="." /></xsl:when>
				<xsl:otherwise>
					<tr>
						<td><xsl:value-of select="name(../..)" />_<xsl:value-of select="name(..)" />_<xsl:value-of select="name()" /></td>
						<td><xsl:value-of select="." /></td>
						<td><xsl:value-of select="@unit" /></td>
					</tr>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="cs:size">
		<tr>
			<td><xsl:value-of select="name(../..)" />_<xsl:value-of select="name(..)" />_<xsl:value-of select="name()" /></td>
			<td><xsl:value-of select="@name" /></td>
			<td />
		</tr>
		<xsl:for-each select="*">
			<tr>
				<td><xsl:value-of select="name(../../..)" />_<xsl:value-of select="name(../..)" />_<xsl:value-of select="name(..)" />_<xsl:value-of select="name()" /></td>
				<td><xsl:value-of select="." /></td>
				<td><xsl:value-of select="@unit" /></td>
			</tr>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="cs:SASdetector">
		<tr>
			<td><xsl:value-of select="name()" /></td>
			<td><xsl:value-of select="cs:name" /></td>
			<td><xsl:value-of select="@name" /></td>
		</tr>
		<xsl:for-each select="*">
			<xsl:choose>
				<xsl:when test="name()='name'" />
				<xsl:when test="name()='offset'"><xsl:apply-templates select="." /></xsl:when>
				<xsl:when test="name()='orientation'"><xsl:apply-templates select="." /></xsl:when>
				<xsl:when test="name()='beam_center'"><xsl:apply-templates select="." /></xsl:when>
				<xsl:when test="name()='pixel_size'"><xsl:apply-templates select="." /></xsl:when>
				<xsl:otherwise>
					<tr>
						<td><xsl:value-of select="name(..)" />_<xsl:value-of select="name()" /></td>
						<td><xsl:value-of select="." /></td>
						<td><xsl:value-of select="@unit" /></td>
					</tr>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="cs:orientation">
		<tr>
			<td><xsl:value-of select="name(..)" />_<xsl:value-of select="name()" /></td>
			<td><xsl:value-of select="@name" /></td>
			<td />
		</tr>
		<xsl:for-each select="*">
			<tr>
				<td><xsl:value-of select="name(../..)" />_<xsl:value-of select="name(..)" />_<xsl:value-of select="name()" /></td>
				<td><xsl:value-of select="." /></td>
				<td><xsl:value-of select="@unit" /></td>
			</tr>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="cs:position">
		<tr>
			<td><xsl:value-of select="name(..)" />_<xsl:value-of select="name()" /></td>
			<td><xsl:value-of select="@name" /></td>
			<td />
		</tr>
		<xsl:for-each select="*">
			<tr>
				<td><xsl:value-of select="name(../..)" />_<xsl:value-of select="name(..)" />_<xsl:value-of select="name()" /></td>
				<td><xsl:value-of select="." /></td>
				<td><xsl:value-of select="@unit" /></td>
			</tr>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="cs:offset">
		<tr>
			<td><xsl:value-of select="name(..)" />_<xsl:value-of select="name()" /></td>
			<td><xsl:value-of select="@name" /></td>
			<td />
		</tr>
		<xsl:for-each select="*">
			<tr>
				<td><xsl:value-of select="name(../..)" />_<xsl:value-of select="name(..)" />_<xsl:value-of select="name()" /></td>
				<td><xsl:value-of select="." /></td>
				<td><xsl:value-of select="@unit" /></td>
			</tr>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="cs:beam_center">
		<tr>
			<td><xsl:value-of select="name(..)" />_<xsl:value-of select="name()" /></td>
			<td><xsl:value-of select="@name" /></td>
			<td />
		</tr>
		<xsl:for-each select="*">
			<tr>
				<td><xsl:value-of select="name(../..)" />_<xsl:value-of select="name(..)" />_<xsl:value-of select="name()" /></td>
				<td><xsl:value-of select="." /></td>
				<td><xsl:value-of select="@unit" /></td>
			</tr>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="cs:pixel_size">
		<tr>
			<td><xsl:value-of select="name(..)" />_<xsl:value-of select="name()" /></td>
			<td><xsl:value-of select="@name" /></td>
			<td />
		</tr>
		<xsl:for-each select="*">
			<tr>
				<td><xsl:value-of select="name(../..)" />_<xsl:value-of select="name(..)" />_<xsl:value-of select="name()" /></td>
				<td><xsl:value-of select="." /></td>
				<td><xsl:value-of select="@unit" /></td>
			</tr>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="cs:term">
		<tr>
			<td><xsl:value-of select="@name" /></td>
			<td><xsl:value-of select="." /></td>
			<td><xsl:value-of select="@unit" /></td>
		</tr>
	</xsl:template>

	<xsl:template match="cs:SASprocessnote" mode="standard">
		<tr>
			<td><xsl:value-of select="name()" /></td>
			<td><xsl:value-of select="." /></td>
			<td><xsl:value-of select="@name" /></td>
		</tr>
	</xsl:template>
	
	<xsl:template match="cs:SASprocessnote" mode="Indra">
		<!-- 
			Customization for APS USAXS metadata
			These will be IgorPro wavenote variables
		-->
		<xsl:for-each select="cs:APS_USAXS">
			<!-- ignore any other elements at this point -->
			<tr>
				<td bgcolor="lightgrey"><xsl:value-of select="name(..)" /></td>
				<td bgcolor="lightgrey"><xsl:value-of select="name()" /></td>
				<td bgcolor="lightgrey"><xsl:value-of select="@name" /></td>
			</tr>
			<xsl:for-each select="*">
				<tr>
					<td><xsl:value-of select="name()" /></td>
					<td><xsl:value-of select="." /></td>
					<td><xsl:value-of select="@name" /></td>
				</tr>
			</xsl:for-each>
		</xsl:for-each>
	</xsl:template>
	
	<xsl:template match="cs:SASprocess">
		<tr>
			<td><xsl:value-of select="name()" /></td>
			<td><xsl:value-of select="cs:name" /></td>
			<td><xsl:value-of select="@name" /></td>
		</tr>
		<xsl:for-each select="*">
			<xsl:choose>
				<xsl:when test="name()='name'" />
				<xsl:when test="name()='term'"><xsl:apply-templates select="." /></xsl:when>
				<xsl:when test="name()='SASprocessnote'">
					<xsl:choose>
						<xsl:when test="../@name='Indra'"><xsl:apply-templates select="." mode="Indra"/></xsl:when>
						<xsl:otherwise><xsl:apply-templates select="." mode="standard"/></xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<tr>
						<td><xsl:value-of select="name(..)" />_<xsl:value-of select="name()" /></td>
						<td><xsl:value-of select="." /></td>
						<td />
					</tr>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="cs:SASnote">
		<xsl:if test="@name!=''">
			<tr>
				<td><xsl:value-of select="name()" /></td>
				<td><xsl:value-of select="." /></td>
				<td><xsl:value-of select="@name" /></td>
			</tr>
		</xsl:if>
	</xsl:template>

</xsl:stylesheet>

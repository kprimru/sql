USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
�����:         ������� �������
��������:      ������� ������ � ���� ������������� �������
*/
CREATE PROCEDURE [dbo].[CLIENT_DISTR_SELECT]
	@clientid INT
AS
BEGIN
	SET NOCOUNT ON
	/*
	SELECT 
		CD_ID, DIS_ID, DIS_STR, CD_REG_DATE, DSS_NAME, DS_NAME
	FROM 
		dbo.ClientDistrView LEFT OUTER JOIN
		dbo.RegNodeTable ON SYS_REG_NAME = RN_SYS_NAME AND
						RN_DISTR_NUM = DIS_NUM AND
						RN_COMP_NUM = DIS_COMP_NUM LEFT OUTER JOIN
		dbo.DistrStatusTable ON DS_REG = RN_SERVICE
	WHERE CD_ID_CLIENT = @clientid
	ORDER BY SYS_ORDER, DIS_NUM
	*/
	
	SELECT 
		CD_ID, DIS_ID, DIS_STR, CD_REG_DATE, DSS_ID, DSS_NAME, DS_NAME,
		SN_NAME,				
		CASE RN_SUBHOST 
			WHEN 1 THEN CONVERT(BIT, 1)
			ELSE CONVERT(BIT, 0)
		END AS RN_SUBHOST,
		CASE 
			WHEN CHARINDEX('(', RN_COMMENT) <> 1 THEN ''
			WHEN CHARINDEX(')', SUBSTRING(RN_COMMENT, CHARINDEX('(', RN_COMMENT) + 1, 
                        LEN(RN_COMMENT) - CHARINDEX('(', RN_COMMENT))) < 2 THEN ''
			ELSE
				SUBSTRING(SUBSTRING(RN_COMMENT, CHARINDEX('(', RN_COMMENT) + 1, 
                        LEN(RN_COMMENT) - CHARINDEX('(', RN_COMMENT)), 1, CHARINDEX(')', SUBSTRING(RN_COMMENT, CHARINDEX('(', RN_COMMENT) + 1, 
                        LEN(RN_COMMENT) - CHARINDEX('(', RN_COMMENT))) - 1)
		END AS SH_PSEDO, SST_CAPTION
	FROM 
		dbo.ClientDistrView LEFT OUTER JOIN
		dbo.RegNodeTable ON SYS_REG_NAME = RN_SYS_NAME AND
						RN_DISTR_NUM = DIS_NUM AND
						RN_COMP_NUM = DIS_COMP_NUM LEFT OUTER JOIN
		dbo.DistrStatusTable ON DS_REG = RN_SERVICE LEFT OUTER JOIN
		dbo.SystemNetCountTable ON SNC_NET_COUNT = RN_NET_COUNT AND SNC_TECH = RN_TECH_TYPE AND SNC_ODON = RN_ODON AND SNC_ODOFF = RN_ODOFF LEFT OUTER JOIN
		dbo.SystemNetTable ON SNC_ID_SN = SN_ID LEFT OUTER JOIN		
		dbo.SystemTypeTable ON SST_NAME = RN_DISTR_TYPE
	WHERE CD_ID_CLIENT = @clientid
	ORDER BY SYS_ORDER, DIS_NUM
END
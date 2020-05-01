USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER VIEW [dbo].[ClientFinancingAddressView]
AS
SELECT 
	CASE ISNULL(FAT_ID_ADDR_TYPE, 0)
		WHEN 0 THEN FAT_TEXT
		ELSE
			CASE ISNULL(ST_ID, 0)
				WHEN 0 THEN CA_STR
				ELSE
					CASE WHEN LTRIM(RTRIM(ISNULL(CA_FREE, ''))) <> '' THEN CA_FREE
					ELSE
						CASE ATL_INDEX 
							WHEN 1 THEN 
								CASE CA_INDEX
									WHEN '' THEN ''
									ELSE ISNULL(CA_INDEX + ', ', '')
								END
							ELSE ''
						END +
						CASE ATL_COUNTRY 
							WHEN 1 THEN ISNULL(CNT_NAME + ', ', '')
							ELSE ''
						END +
						CASE ATL_REGION 
							WHEN 1 THEN ISNULL(RG_NAME + ', ', '')
							ELSE ''
						END +
						CASE ATL_AREA 
							WHEN 1 THEN ISNULL(AR_NAME + ', ', '')
							ELSE ''
						END +
						CASE ATL_CITY_PREFIX 
							WHEN 1 THEN ISNULL(CT_PREFIX, '')
							ELSE ''
						END + 
						CASE ATL_CITY
							WHEN 1 THEN ISNULL(CT_NAME + ', ', '')
							ELSE ''
						END +
						CASE ATL_STR_PREFIX 
							WHEN 1 THEN ISNULL(ST_PREFIX + ' ', '')
							ELSE ''
						END + 
						CASE ATL_STREET
							WHEN 1 THEN ISNULL(ST_NAME, '')
							ELSE ''
						END +
						CASE ATL_STR_PREFIX
							WHEN 1 THEN ISNULL(' ' + ST_SUFFIX, '')
							ELSE ''
						END +
						CASE ATL_HOME
							WHEN 1 THEN ISNULL(', ' + CA_HOME, '')
							ELSE ''
						END 
					END
			END
	END	AS ADDR_STRING, CFA_ID, FAT_ID, FAT_NOTE, E.ATL_ID, E.ATL_CAPTION, CL_ID,
	D.CA_ID_TYPE AS CA_ID_TYPE
FROM
	dbo.FinancingAddressTypeTable	A									LEFT OUTER JOIN
	dbo.ClientFinancingAddressTable	B	ON	A.FAT_ID = B.CFA_ID_FAT	
																	LEFT OUTER JOIN
	dbo.ClientTable					C	ON	B.CFA_ID_CLIENT = C.CL_ID	LEFT OUTER JOIN
	dbo.ClientAddressView			D	ON	C.CL_ID = D.CA_ID_CLIENT	
									AND A.FAT_ID_ADDR_TYPE = D.CA_ID_TYPE
																	INNER JOIN
	dbo.AddressTemplateTable		E	ON	E.ATL_ID = B.CFA_ID_ATL
--WHERE ISNULL(A.FAT_ID_ADDR_TYPE, D.CA_ID_TYPE) = D.CA_ID_TYPE

USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




/*
јвтор:			ƒенисов јлексей
ƒата:			17.07.2009
ќписание:		данные шаблона фин.документа клиента,
				если cfaid не нуль (фин.документ имеет заданный шаблон), возвращаютс€
				его данные, иначе можно указать шаблон по умолчанию в поле ATL_ID
*/

CREATE PROCEDURE [dbo].[CLIENT_FINANCING_ADDRESS_GET] 
	@cfaid INT,
	@fatid SMALLINT

AS
BEGIN
	SET NOCOUNT ON
	IF ((@cfaid IS NOT NULL) AND (@cfaid <> 0))
	BEGIN
		SELECT CFA_ID, FAT_ID, FAT_NOTE, FAT_DOC, ATL_ID, ATL_CAPTION
			FROM	dbo.FinancingAddressTypeTable	A		LEFT OUTER JOIN
					dbo.AddressTypeTable			B	ON	A.FAT_ID_ADDR_TYPE=B.AT_ID LEFT OUTER JOIN
					dbo.ClientFinancingAddressTable C	ON	C.CFA_ID_FAT = A.FAT_ID LEFT OUTER JOIN
					dbo.AddressTemplateTable		D	ON	C.CFA_ID_ATL = D.ATL_ID
		WHERE
			CFA_ID = @cfaid
		ORDER BY AT_NAME
	END
	ELSE
	BEGIN
		SELECT FAT_ID, FAT_NOTE, FAT_DOC, 1 AS ATL_ID, '' AS ATL_CAPTION
			FROM	dbo.FinancingAddressTypeTable
			WHERE
			FAT_ID = @fatid
		ORDER BY FAT_NOTE
		
	END
	
	SET NOCOUNT OFF
END













USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




/*
Автор:			Денисов Алексей
Дата:			17.07.2009
Описание:		данные шаблона фин.документа клиента,
				если cfaid не нуль (фин.документ имеет заданный шаблон), возвращаются
				его данные, иначе можно указать шаблон по умолчанию в поле ATL_ID
*/

ALTER PROCEDURE [dbo].[CLIENT_FINANCING_ADDRESS_GET]
	@cfaid INT,
	@fatid SMALLINT

AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

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

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_FINANCING_ADDRESS_GET] TO rl_client_fin_template_r;
GO

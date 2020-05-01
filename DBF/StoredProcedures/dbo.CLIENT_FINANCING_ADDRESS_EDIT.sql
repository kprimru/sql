USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




/*
Автор:			Денисов Алексей
Описание:		Изменение шаблона адреса в фин.док-те клиента
				Если @cfaid не нуль (адрес фин.документа имеет заданный шаблон),
				изменяется его шаблон на @atlid, иначе типу адреса в док-те @fatid 
				присваивается шаблон @atlid.
Дата:			17.07.2009
*/

ALTER PROCEDURE [dbo].[CLIENT_FINANCING_ADDRESS_EDIT] 
	@cfaid INT,
	@atlid SMALLINT,
	@clid INT,
	@fatid SMALLINT
AS

BEGIN
	SET NOCOUNT ON

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
				UPDATE dbo.ClientFinancingAddressTable
				SET CFA_ID_ATL = @atlid
				WHERE CFA_ID = @cfaid
				
				SELECT @cfaid AS NEW_IDEN
			END
		ELSE
			BEGIN
				INSERT INTO dbo.ClientFinancingAddressTable (
						CFA_ID_CLIENT, CFA_ID_FAT, CFA_ID_ATL
					) VALUES (
						@clid, @fatid, @atlid
					)

				SELECT SCOPE_IDENTITY() AS NEW_IDEN
			END

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [dbo].[CLIENT_FINANCING_ADDRESS_EDIT] TO rl_client_fin_template_w;
GO
USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[DBF_CACHE_SYNC]
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@Number		Int,
		@Msg		NVarChar(2048),
		@Message	NVarChar(Max);


	WHILE (1 = 1) BEGIN
		BEGIN TRY
			EXEC dbo.DBF_CACHE_SYNC_INTERNAL;
			
			-- ждем минуту до следующего запуска
			WAITFOR DELAY '00:01';
		END TRY
		BEGIN CATCH
			SELECT 
				@Number	=	ERROR_NUMBER(),
				@Msg	=	ERROR_MESSAGE()
				
			SET @Message = 'Произошла ошибка: "' + @Msg + '". Номер ошибки: ' + Cast(@Number AS NVarChar(Max));
				
			EXEC [Maintenance].[MAIL_SEND] @Message;
			
			RETURN;
		END CATCH
	END;
END

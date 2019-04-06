USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:		  Денисов Алексей
Описание:	  
*/

CREATE PROCEDURE [dbo].[CLIENT_CHECK_PSEDO] 
	@psedo VARCHAR(100),
	@clientid INT
AS
BEGIN
	SET NOCOUNT ON

	IF @clientid IS NULL
		SELECT CL_ID 
		FROM dbo.ClientTable
		WHERE CL_PSEDO = @psedo
	ELSE
		SELECT CL_ID 
		FROM dbo.ClientTable
		WHERE CL_PSEDO = @psedo AND CL_ID <> @clientid

	SET NOCOUNT OFF
END





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

CREATE PROCEDURE [dbo].[ACTION_TYPE_EDIT] 
	@id SMALLINT,
	@name VARCHAR(100),
	@active BIT = 1
AS
BEGIN
	SET NOCOUNT ON

	UPDATE dbo.ActionType
	SET ACTT_NAME = @name,
		ACTT_ACTIVE = @active
	WHERE ACTT_ID = @id

	SET NOCOUNT OFF
END

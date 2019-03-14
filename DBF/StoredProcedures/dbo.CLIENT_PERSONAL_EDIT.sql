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

CREATE PROCEDURE [dbo].[CLIENT_PERSONAL_EDIT] 
	@personalid INT,
	@surname VARCHAR(100),
	@name VARCHAR(100),
	@otch VARCHAR(100),
	@positionid SMALLINT,
	@reportpositionid SMALLINT
--  @phone varchar(100)
AS
BEGIN
	SET NOCOUNT ON

	UPDATE dbo.ClientPersonalTable 
	SET	PER_FAM = @surname, PER_NAME = @name, PER_OTCH = @otch,
		PER_ID_POS = @positionid, PER_ID_REPORT_POS = @reportpositionid
	--, PER_PHONE = @phone
	WHERE PER_ID = @personalid


	SET NOCOUNT OFF
END
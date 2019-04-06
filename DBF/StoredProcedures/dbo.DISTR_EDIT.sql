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

CREATE PROCEDURE [dbo].[DISTR_EDIT] 
	@distrid INT,
	@systemid INT,
	@distrnum INT,
	@compnum TINYINT,
	@active BIT = 1
AS
BEGIN
	SET NOCOUNT ON

	UPDATE dbo.DistrTable 
	SET DIS_ID_SYSTEM = @systemid, 
		DIS_NUM = @distrnum, 
		DIS_COMP_NUM = @compnum,
		DIS_ACTIVE = @active
	WHERE DIS_ID = @distrid

	SET NOCOUNT OFF
END
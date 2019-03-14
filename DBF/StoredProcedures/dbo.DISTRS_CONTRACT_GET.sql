USE [DBF]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	
/*
Author:		%authorname%
Create date: 2009-02-02
Description:	Выдаёт список дистрибутивов
			договора по заданному контракту
*/

CREATE PROCEDURE [dbo].[DISTRS_CONTRACT_GET]
	@co_id INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT *
	FROM dbo.DistrsContractView
	WHERE CO_ID = @co_id
END
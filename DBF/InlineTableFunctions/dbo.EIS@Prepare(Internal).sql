USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [dbo].[EIS@Prepare(Internal)]
(
	@Act_Id	Integer
)
RETURNS TABLE
AS
RETURN
(
    SELECT
		[File_Id]    = Cast((SELECT [NewId] FROM [dbo].[NewIdView]) AS VarChar(100)),
        [IdentGUId]  = Replace(Cast((SELECT [NewId] FROM [dbo].[NewIdView]) AS VarChar(100)), '-', '')
	-- TODO сделать исключение в функции, чтобы можно было ошибку кидать при проверке по act_id
)
GO

USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GET_DISTR_TYPE] 
AS
BEGIN
	SET NOCOUNT ON

	SELECT DistrTypeID, DistrTypeName, DistrTypeName AS DistrTypeShortName
	FROM dbo.DistrTypeTable
	ORDER BY DistrTypeOrder
END
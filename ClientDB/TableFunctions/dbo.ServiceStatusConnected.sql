USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [dbo].[ServiceStatusConnected]()
RETURNS @Result TABLE
(
	ServiceStatusId SmallInt PRIMARY KEY CLUSTERED
)
AS
BEGIN
	DECLARE @Tmp Table
	(
		ServiceStatus_Id Sql_Variant
	);

	INSERT INTO @Tmp
	SELECT SetItem
	FROM dbo.NamedSetItemsSelect('dbo.ServiceStatusTable', 'Пополняемые')

	INSERT INTO @Result
	SELECT Cast(ServiceStatus_Id AS SmallInt)
	FROM @Tmp

	RETURN
END
GO

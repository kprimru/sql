USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[ServiceStatusConnected]()
RETURNS TABLE AS RETURN
(
	SELECT ServiceStatusId = Cast(SetItem AS SmallInt)
	FROM dbo.NamedSetItemsSelect('dbo.ServiceStatusTable', 'Пополняемые')
)

USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Maintenance].[JOB_SETTINGS_SELECT]
AS
	SELECT Id, Name, ExpireTime 
	FROM Maintenance.JobType

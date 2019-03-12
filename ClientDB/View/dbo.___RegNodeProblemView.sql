USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE VIEW [dbo].[RegNodeProblemView]
AS
	SELECT 
		SystemName, DistrNumber, CompNumber, Service, NetCount, TechnolType, DistrType, Comment, Complect,
		CONVERT(BIT, CASE
			WHEN SystemName = 'ROS' AND DistrType NOT IN('NCT', 'HSS', 'NEK', 'DSP', 'SPF')
				AND NOT EXISTS 
					(
						SELECT * 
						FROM dbo.RegNodeTable b 
						WHERE a.Complect = b.Complect 
							AND b.DistrType NOT IN('NCT', 'HSS', 'NEK', 'DSP', 'SPF')
							AND b.Service = 0
							AND b.SystemName IN ('CMT', 'QSA', 'BORG', 'FIN')
					) THEN 1
			ELSE 0
		END) AS Problem
	FROM dbo.RegNodeTable a
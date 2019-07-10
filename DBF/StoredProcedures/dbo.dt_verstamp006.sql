USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
**	This procedure returns the version number of the stored
**    procedures used by the Microsoft Visual Database Tools.
**    Current version is 7.0.00.
*/
create procedure dbo.dt_verstamp006
as
	select 7000

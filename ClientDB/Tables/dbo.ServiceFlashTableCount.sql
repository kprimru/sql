USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ServiceFlashTableCount]
(
        [ID_FLASH]    VarChar(1023)      NOT NULL,
        [LAST_DATE]   SmallDateTime          NULL,
);
GO
GRANT DELETE ON [dbo].[ServiceFlashTableCount] TO public;
GRANT INSERT ON [dbo].[ServiceFlashTableCount] TO public;
GRANT SELECT ON [dbo].[ServiceFlashTableCount] TO public;
GRANT UPDATE ON [dbo].[ServiceFlashTableCount] TO public;
GO

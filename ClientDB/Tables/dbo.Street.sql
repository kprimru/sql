USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Street]
(
        [ST_ID]        UniqueIdentifier      NOT NULL,
        [ST_ID_CITY]   UniqueIdentifier      NOT NULL,
        [ST_NAME]      VarChar(150)          NOT NULL,
        [ST_PREFIX]    VarChar(20)           NOT NULL,
        [ST_SUFFIX]    VarChar(20)           NOT NULL,
        CONSTRAINT [PK_dbo.Street] PRIMARY KEY CLUSTERED ([ST_ID]),
        CONSTRAINT [FK_dbo.Street(ST_ID_CITY)_dbo.City(CT_ID)] FOREIGN KEY  ([ST_ID_CITY]) REFERENCES [dbo].[City] ([CT_ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_dbo.Street(ST_NAME)+(ST_ID,ST_ID_CITY)] ON [dbo].[Street] ([ST_NAME] ASC) INCLUDE ([ST_ID], [ST_ID_CITY]);
GO

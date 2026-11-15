package com.second.hand.trading.server.dao;

import com.second.hand.trading.server.model.FavoriteModel;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface FavoriteDao {
    int deleteByPrimaryKey(Long id);

    int insert(FavoriteModel record);

    int insertSelective(FavoriteModel record);

    FavoriteModel selectByPrimaryKey(Long id);

    List<FavoriteModel> getMyFavorite(@Param("userId") Long userId);

    Integer checkFavorite(@Param("userId") Long userId, @Param("idleId") Long idleId);

    int updateByPrimaryKeySelective(FavoriteModel record);

    int updateByPrimaryKey(FavoriteModel record);
}

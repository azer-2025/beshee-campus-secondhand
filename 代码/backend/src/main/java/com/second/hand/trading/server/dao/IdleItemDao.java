package com.second.hand.trading.server.dao;

import com.second.hand.trading.server.model.IdleItemModel;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.Map;

@Mapper
public interface IdleItemDao {
    int deleteByPrimaryKey(Long id);

    int insert(IdleItemModel record);

    int insertSelective(IdleItemModel record);

    IdleItemModel selectByPrimaryKey(Long id);

    List<IdleItemModel> getAllIdleItem(Long userId);

    int countIdleItem(@Param("findValue") String findValue);

    int countIdleItemByLable(int idleLabel);

    int countIdleItemByStatus(int status);

    List<IdleItemModel> findIdleItem(@Param("findValue") String findValue,
                                     @Param("begin") int begin,
                                     @Param("nums") int nums);

    List<IdleItemModel> findIdleItem1(@Param("findValue") String findValue,
                                      @Param("status") int status,
                                      @Param("begin") int begin,
                                      @Param("nums") int nums);

    List<IdleItemModel> findIdleItemByLable(@Param("idleLabel") int idleLabel,
                                            @Param("begin") int begin,
                                            @Param("nums") int nums);

    List<IdleItemModel> getIdleItemByStatus(@Param("status") int status,
                                            @Param("begin") int begin,
                                            @Param("nums") int nums);

    int updateByPrimaryKeySelective(IdleItemModel record);

    int updateByPrimaryKey(IdleItemModel record);

    List<IdleItemModel> findIdleByList(List<Long> idList);
    
    /**
     * 统计各个分类的商品数量
     * @return 包含分类ID和对应数量的列表
     */
    List<Map<String, Object>> countItemsByCategory();
}
